import pandas as pd
import sqlalchemy
from dotenv import dotenv_values


def get_sql_config():
    '''
    loads credentials and parameters from '.env' file and returns a
    dictionary containing those needed for sqlalchemy.create_engine()
    '''
    needed_keys = [
          'host'
        , 'port'
        , 'database'
        , 'user'
        , 'password'
        , 'options'
    ]
    dotenv_dict = dotenv_values(".env")
    return {
        key: dotenv_dict[key] for key in needed_keys if key in dotenv_dict
    }

def get_engine():
    '''
    returns sqlalchemy connection engine for the PostgreSQL database
    (configured via '.env')
    '''
    return sqlalchemy.create_engine(
          'postgresql://user:pass@host/database'
        , connect_args=get_sql_config()
    )

def get_data(sql_query):
    '''
    returns the result as a list after running sql_query on the PostgreSQL
    database (configured via '.env')
    '''
    # open conn session using 'with', execute the query, and return the results
    with get_engine().begin() as conn:
        return conn.execute(sql_query).fetchall()

def get_dataframe(sql_query):
    '''
    returns the result as a dataframe after running sql_query on the PostgreSQL
    database (configured via '.env')
    '''
    return pd.read_sql_query(sql=sql_query, con=get_engine())
