import jenkins_helper
import json
import requests

def handler(event, context):
    try:
        print('Event', event)
        print('Context', context)

        resourceProps = event['ResourceProperties']

        jenkins_info = {
            'host': resourceProps['JenkinsHost'],
            'username': resourceProps['JenkinsUsername'],
            'api_token': resourceProps['JenkinsApiToken']
        }
        
        jenkins_job_name = resourceProps['JobName']
        jenkins_job_pipeline = resourceProps['JobPipeline']

        if event['RequestType'] == 'Delete':
            response = jenkins_helper.delete_job(
                jenkins_info, 
                jenkins_job_name
            )
        else:
            response = jenkins_helper.create_or_update_job(
                jenkins_info, 
                jenkins_job_name, 
                jenkins_job_pipeline
            )

        print(response.text)

        if (response.status_code == 200):
            sendCloudFormationResponse(event, context, "SUCCESS")
        else:
            raise Exception('Error requesting Jenkins: ' + str(response.status_code))
    except Exception as e:
        print(e)
        sendCloudFormationResponse(event, context, "FAILED")
        
def sendCloudFormationResponse(event, context, status):
    response_body = {
        'Status': status,
        'Reason': 'Log stream name: ' + context.log_stream_name,
        'PhysicalResourceId': event['ResourceProperties']['JobName'],
        'StackId': event['StackId'],
        'RequestId': event['RequestId'],
        'LogicalResourceId': event['LogicalResourceId'],
        'Data': json.loads('{}')
    }

    requests.put(event['ResponseURL'], data=json.dumps(response_body))
