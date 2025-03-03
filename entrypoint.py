import os
from dbt.cli.main import dbtRunner, dbtRunnerResult
from datetime import datetime
from dotenv import load_dotenv
load_dotenv()


def run_action(dbt_action):
    if dbt_action == "run":
        print('RUNNING DBT')
        # initialize
        dbt = dbtRunner()

        # create CLI args as a list of strings
        cli_args = ["run", "--select", "dbt_top_10_offers"]

        # run the command
        res: dbtRunnerResult = dbt.invoke(cli_args)

        # inspect the results
        for r in res.result:
            print(f"{r.node.name}: {r.status}")

    elif dbt_action == "test":
        print('TESTING DBT')
        # initialize
        dbt = dbtRunner()

        # create CLI args as a list of strings
        cli_args = ["test",]

        # run the command
        res: dbtRunnerResult = dbt.invoke(cli_args)

        # inspect the results
        for r in res.result:
            print(f"{r.node.name}: {r.status}")
    elif dbt_action == "report":
        print('SENDING REPORT TO S3')

        cmd = (
            f"edr send-report --aws-access-key-id {AWS_ACCESS_KEY_ID} "
            f"--aws-secret-access-key {AWS_SECRET_ACCESS_KEY} "
            # f"--aws-profile-name {AWS_PROFILE_NAME} "
            f"--s3-bucket-name {AWS_S3_BUCKET_NAME}  "
            f"--profiles-dir . "
            f"--bucket-file-path=dbt_elementary_report_{datetime.now().isoformat()}.html"
        )
        os.system(cmd)
    else:
        print('Invalid action')

# https://docs.elementary-data.com/oss/guides/share-observability-report/send-report-summary
if __name__ == '__main__':
    DBT_ACTION = os.getenv('DBT_ACTION', 'run')
    AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
    AWS_PROFILE_NAME = os.getenv('AWS_PROFILE_NAME')
    AWS_S3_BUCKET_NAME = os.getenv('AWS_S3_BUCKET_NAME')
    run_action(DBT_ACTION)