import oracledb
import os
import yaml

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(project_root, "shared", "config.yaml")

with open(config_path, 'r', encoding='utf-8') as cf:
    config = yaml.safe_load(cf)

username = config['oracle']['username']
password = config['oracle']['password']
dsn = config['oracle']['dsn']

def get_connection():

    connection = oracledb.connect(user=username, password=password, dsn=dsn)

    return connection
