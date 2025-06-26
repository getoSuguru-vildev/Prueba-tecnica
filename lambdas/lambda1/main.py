import os
import json
import requests

def lambda_handler(event, context):
    print("Lambda1 invocada correctamente")
    return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Hola Mundo"
            })
        }
