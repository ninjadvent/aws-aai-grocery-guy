import json
import os
import subprocess

def main(event, context):
    try:
        # Load environment variables
        openai_api_key = os.environ.get("OPENAI_API_KEY")
        llama_ocr_api_key = os.environ.get("LLAMA_OCR_API_KEY")

        # Check if API keys are set
        if not openai_api_key:
            return {
                "statusCode": 500,
                "body": json.dumps({"error": "OPENAI_API_KEY is not set"})
            }

        # Set environment variables for the subprocess
        env = os.environ.copy()
        env["OPENAI_API_KEY"] = openai_api_key
        if llama_ocr_api_key:
            env["LLAMA_OCR_API_KEY"] = llama_ocr_api_key
        
        if "image" in event:
            # Run the grocery_management_agents_system.ipynb notebook
            process = subprocess.Popen(
                ["jupyter", "nbconvert", "--to", "json", "--execute", "/app/grocery_management_agents_system.ipynb"],
                cwd="/tmp",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=env
            )

            stdout, stderr = process.communicate()

            if process.returncode != 0:
                return {
                    "statusCode": 500,
                    "body": json.dumps({"error": f"Failed to execute notebook: {stderr.decode()}"})
                }

            # Return the output
            return {
                "statusCode": 200,
                "body": stdout.decode()
            }
        else:
            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Lambda function invoked successfully with dummy data!"})
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
