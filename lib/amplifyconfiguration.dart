
const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ca-central-1_NnAEFnZHw", // <-- YOUR USER POOL ID
            "AppClientId": "43ilveobu7f5jq0nleio6scnc5", // <-- YOUR APP CLIENT ID
            "Region": "ca-central-1" // <-- YOUR REGION
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH"
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "foodlogapi": {
          "endpointType": "REST",
          "endpoint": "https://ebiclbvl5j.execute-api.ca-central-1.amazonaws.com/dev", // <-- YOUR API URL
          "region": "ca-central-1", // <-- YOUR REGION
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  }
}''';