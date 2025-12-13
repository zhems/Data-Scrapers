import io
import os

import pandas as pd
import requests

headers = {"x-api-key": os.getenv("DATA_GOV_API_KEY")}


# url2 = f'https://api-open.data.gov.sg/v1/public/api/datasets/{datasetId}/poll-download'
def get_csv_file(dataset_id: str) -> pd.DataFrame:
    response = requests.get(
        f"https://api-open.data.gov.sg/v1/public/api/datasets/{dataset_id}/initiate-download",
        headers,
    )

    data_response = requests.get(response.json()["data"]["url"])
    df = pd.read_csv(io.BytesIO(data_response.content))

    # Optional cleaning steps
    if "transaction_date" in df.columns:
        df["transaction_date"] = pd.to_datetime(
            df["transaction_date"], format="%b-%Y"
        ).dt.date

    return df
