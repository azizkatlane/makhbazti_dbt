import dlt
#import pandas as pd
#import json
import openmeteo_requests
from datetime import datetime , timedelta
import requests_cache
from retry_requests import retry
from dlt.sources.helpers import requests

# Setup the Open-Meteo API client with cache and retry on error
cache_session = requests_cache.CachedSession('.cache', expire_after = -1)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)



coordinates_location = {
    "ولاية تونس" : (36.801403 , 10.170828),
    "ولاية منوبة": (36.801403, 10.052563),
    "ولاية اريانة": (36.871704, 10.184211),
    "ولاية بن عروس": (36.731106, 10.275591),
    "ولاية مدنين": (33.356766, 10.555555)
}

WMO_CODES = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Depositing rime fog",
    51: "Light drizzle",
    53: "Moderate drizzle",
    55: "Dense drizzle",
    56: "Light freezing drizzle",
    57: "Dense freezing drizzle",
    61: "Slight rain",
    63: "Moderate rain",
    65: "Heavy rain",
    66: "Light freezing rain",
    67: "Heavy freezing rain",
    71: "Slight snow fall",
    73: "Moderate snow fall",
    75: "Heavy snow fall",
    77: "Snow grains",
    80: "Slight rain showers",
    81: "Moderate rain showers",
    82: "Violent rain showers",
    85: "Slight snow showers",
    86: "Heavy snow showers",
    95: "Thunderstorm",
    96: "Thunderstorm with slight hail",
    99: "Thunderstorm with heavy hail"
}

pipeline=dlt.pipeline(
    import_schema_path="schemas/import",
    export_schema_path="schemas/export",
    pipeline_name="weather_dlt_api",
    destination="postgres",
    dataset_name="weather_api"
)

with pipeline.sql_client() as client:
    last_run = client.execute_sql("select MAX(value) from weather__daily__time")
    print(f"last run was { last_run[0][0].strftime('%Y-%m-%d')}")

# end_date is today - 2 days due to api data refresh (to be sure we get consistent data)

start_d=(last_run[0][0] + timedelta(days=1)).strftime("%Y-%m-%d")
end_d=(datetime.today()-timedelta(days=2)).strftime("%Y-%m-%d")



params = {
	"latitude": [lat for lat, lon in coordinates_location.values()],
    "longitude": [lon for lat, lon in coordinates_location.values()],
	"start_date": start_d,
	"end_date": end_d,
	"daily": ["weather_code", "temperature_2m_max", "temperature_2m_min", "temperature_2m_mean", "apparent_temperature_max", "apparent_temperature_min", "apparent_temperature_mean", "daylight_duration", "precipitation_sum", "rain_sum"],
	"timezone": "auto"
}


def get_region_name(lat, lon):
    for name , coord in coordinates_location.items():
        if coord==(lat, lon):
            return name
        
@dlt.resource(table_name="weather", write_disposition="append")
def weather():
    url = "https://archive-api.open-meteo.com/v1/archive"
    responses = requests.get(url, params=params).json()
    #responses.raise_for_status()
    for response in responses:
        lat = response.get('latitude')
        lon = response.get('longitude')
        
        # Identify the region
        region = get_region_name(lat, lon)
        
        # Add the region field to the response
        response['region'] = region
        
        
        daily_data = response.get('daily', {})
        weather_codes = daily_data.get('weather_code', [])
        descriptions = [WMO_CODES.get(code, "Unknown") for code in weather_codes]
        daily_data['weather_description'] = descriptions
        
        # Add the processed daily weather data back to the response
        response['daily'] = daily_data

        yield response





info=pipeline.run(weather , refresh="drop_resources")




print(info)