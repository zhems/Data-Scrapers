import os
from datetime import datetime

from dotenv import load_dotenv
from sqlalchemy import create_engine

from data_gov_sg import load_dataset

# Load environment variables
load_dotenv()

# Dataset configuration
cea_dataset_id = "d_ee7e46d3c57f7865790704632b0aef71"


def load_to_postgres(df, table_name, connection_string):
    """
    Load DataFrame to PostgreSQL table

    Args:
        df: pandas DataFrame to load
        table_name: Name of the target table
        connection_string: PostgreSQL connection string
    """
    # Add metadata
    df["loaded_at"] = datetime.utcnow()

    # Create SQLAlchemy engine
    engine = create_engine(connection_string)

    # Load data to PostgreSQL
    # if_exists='replace' will drop and recreate the table
    # Use 'append' to add to existing data
    df.to_sql(
        name=table_name,
        con=engine,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=1000,
    )

    print(f"✓ Loaded {len(df)} rows to {table_name}")
    engine.dispose()


if __name__ == "__main__":
    # Load dataset from data.gov.sg
    print("Fetching CEA property transactions data...")
    cea_df = load_dataset(cea_dataset_id)
    print(f"Retrieved {len(cea_df)} records")
    print(f"\nColumns: {list(cea_df.columns)}")
    print(f"\nSample data:\n{cea_df.head()}")

    # Load to PostgreSQL
    connection_string = os.getenv("PSQL_CONNECTION_STRING")
    if connection_string:
        print("\nLoading data to PostgreSQL...")
        load_to_postgres(cea_df, "raw_cea_property_transactions", connection_string)
    else:
        print("Warning: PSQL_CONNECTION_STRING not found in environment variables")
