import dlt
from dlt.common import pendulum
from dlt.common.data_writers import TDataItemFormat
from dlt.common.pipeline import LoadInfo
from dlt.common.typing import TDataItems
from dlt.pipeline.pipeline import Pipeline
from geopy.geocoders import Nominatim

geolocator=Nominatim(user_agent="makhbazti")
# As this pipeline can be run as standalone script or as part of the tests, we need to handle the import differently.
try:
    from .mongodb import mongodb, mongodb_collection  # type: ignore
except ImportError:
    from mongodb import mongodb, mongodb_collection




def stores() -> TDataItems:
    """Load the stores collection"""
    # By default the mongo source reflects all collections in the database
    source = mongodb().with_resources("stores")
    source.resources["stores"].apply_hints(columns={"location": {"data_type": "complex"}})

    for row in source:
        coordinates=row.get("location" , {}).get("coordinates" , [])
        latitude = coordinates[0]
        longitude = coordinates[1]

        address=geolocator.reverse(f"{latitude},{longitude}").raw['address']
        state = address.get('state', '')
        
        row['gouvernorat'] = state

    yield row

def stores_loading(data : TDataItems ,pipeline: Pipeline = None) -> LoadInfo:
    """Use the mongo source to load the stores collection"""
    if pipeline is None:
        # Create a pipeline
        pipeline = dlt.pipeline(
            import_schema_path="schemas/import",
            export_schema_path="schemas/export",
            pipeline_name="LOADING STORES",
            destination='postgres',
            dataset_name="public",
            progress='log'
        )

    

    
    hints = {
            "write_disposition": "merge",
            "primary_key": "_id",
            "columns": {"updated_at":{"dedup_sort":"desc"}}
        }


    # Run the pipeline. For a large db this may take a while
    info = pipeline.run(data, **hints)
    return info


def load_select_collection_db(pipeline: Pipeline = None) -> LoadInfo:
    """Use the mongodb source to reflect an entire database schema and load select tables from it.

    This example sources data from a sample mongo database data from [mongodb-sample-dataset](https://github.com/neelabalan/mongodb-sample-dataset).
    """
    if pipeline is None:
        # Create a pipeline
        pipeline = dlt.pipeline(
            import_schema_path="schemas/import",
            export_schema_path="schemas/export",
            pipeline_name="LOADING PRODUCTS_PROMOTIONS_PAYMENTMETHODS_EMPLOYEES",
            destination='postgres',
            dataset_name="public",
            progress='log'
        )

    
    mflix = mongodb().with_resources(
        "products","paymentMethods","employees"
    )
    mflix.resources['products'].apply_hints(columns={"price": {"data_type": "double", "nullable": True}})

    hints = {
            "write_disposition": "merge",
            "primary_key": "_id",
            "columns": {"updated_at":{"dedup_sort":"desc"}}
        }

    # Run the pipeline. The merge write disposition merges existing rows in the destination by primary key
    info = pipeline.run(mflix, **hints , refresh="drop_resources")

    return info


def load_sales_collection(pipeline: Pipeline = None) -> LoadInfo:
    if pipeline is None:
        # Create a pipeline
        pipeline = dlt.pipeline(
            import_schema_path="schemas/import",
            export_schema_path="schemas/export",
            pipeline_name="LOADING SALES",
            destination='postgres',
            dataset_name="public",
            progress='log'
        )

    # Load a table incrementally with append write disposition
    # this is good when a table only has new rows inserted, but not updated
    sales_collection = mongodb_collection(
        collection="sales",
        incremental=dlt.sources.incremental(
        "createdAt"
    ))


    info = pipeline.run(sales_collection, write_disposition="append" , refresh="drop_resources" )

    return info

def load_products_collection(pipeline: Pipeline = None) -> LoadInfo:
 
    if pipeline is None:
        # Create a pipeline
        pipeline = dlt.pipeline(
            import_schema_path="schemas/import",
            export_schema_path="schemas/export",
            pipeline_name="LOADING PRODUCTS",
            destination='postgres',
            dataset_name="public",
            progress='log'
        )

    # Configure the source to load a few select collections incrementally
    p = mongodb().with_resources("products")

    hints = {
            "write_disposition": "merge",
            "primary_key": "_id",
            "columns": {"updated_at":{"dedup_sort":"desc"}}
        }

    # Run the pipeline. The merge write disposition merges existing rows in the destination by primary key
    info = pipeline.run(p, **hints )

    return info





if __name__ == "__main__":
    # Credentials for the sample database.
    # Load selected tables with different settings
    print(stores_loading(stores()))
    print(load_sales_collection())
    print(load_select_collection_db())