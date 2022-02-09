import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def list_versions(lambda_name):
    cl_lambda = boto3.client('lambda')
    result = []
    response = cl_lambda.list_versions_by_function(FunctionName=lambda_name,MaxItems=1)
    while True:
        para=[]
        para.append (response['Versions'][0]['CodeSha256'])
        para.append (response['Versions'][0]['FunctionArn'])
        logger.info('Version detected: ')
        logger.info(para)
        result.append(para)
        try:
            marker = response['NextMarker']
        except:
            return result
        response = cl_lambda.list_versions_by_function(
            FunctionName=lambda_name,
            MaxItems=1,
            Marker=marker
        )
    return result

def find_latest_sha(info):
    for x in info:
        if (x[1][-6:]) == 'LATEST':
            logger.info('Latest SHA detected: ')
            logger.info(x[0])
            return (x[0])
    return 0

def find_latest_number(info,sha):
    for x in info:
        if ((x[0] == sha) and (x[1][-6:] != 'LATEST')):
            logger.info('Latest decoded to: ')
            logger.info(x[1])
            return(x[1])
    return 0

def lambda_handler(event, context):
    info = list_versions(event['lambda_name'])
    return(find_latest_number(info,find_latest_sha(info)))
