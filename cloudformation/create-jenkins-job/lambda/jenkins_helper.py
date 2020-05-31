import re
import requests
from xml.etree.ElementTree import Element, SubElement, Comment, tostring

def create_or_update_job(jenkins_info, jobname, pipeline_script):
    job_already_exists = check_job_exists(jenkins_info, jobname)

    jenkins_url = f'{jenkins_info["host"]}/createItem?name={jobname}'

    if (job_already_exists):
        jenkins_url = f'{jenkins_info["host"]}/job/{jobname}/config.xml'

    xml = create_job_xml(pipeline_script)

    print('POSTing Jenkins at', jenkins_url, 'with the following pipeline XML:', xml)

    return requests.post(
        jenkins_url,
        data=xml,
        auth=(jenkins_info['username'], jenkins_info['api_token']),
        headers={
            'content-type': 'text/xml'
        }
    )

def check_job_exists(jenkins_info, jobname):
    response = requests.get(
        f'{jenkins_info["host"]}/job/{jobname}/config.xml',
        auth=(jenkins_info['username'], jenkins_info['api_token']),
    )

    return response.status_code != 404

def create_job_xml(pipeline_script):
    root = Element('flow-definition', plugin='workflow-job@2.39')
    SubElement(root, 'description')
    SubElement(root, 'keepDependencies').text = 'false'
    SubElement(root, 'properties')
    SubElement(root, 'triggers')
    SubElement(root, 'disabled').text = 'false'

    definition = SubElement(root, 'definition', plugin='workflow-cps@2.80')
    definition.set('class', 'org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition')
    SubElement(definition, 'script').text = pipeline_script
    SubElement(definition, 'sandbox').text = 'true'

    return tostring(root)

def delete_job(jenkins_info, jobname):
    job_exists = check_job_exists(jenkins_info, jobname)

    if (not job_exists):
        print(f'Cannot delete the job {jobname} because it does not exists')
        return

    jenkins_url = f'{jenkins_info["host"]}/job/{jobname}/doDelete'

    return requests.post(
        jenkins_url,
        auth=(jenkins_info['username'], jenkins_info['api_token'])
    )