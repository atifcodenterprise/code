# create api
resource "aws_api_gateway_rest_api" "orangutan_api" {
  body = jsonencode(
    { # EXAMPLE one
      "openapi" : "3.0.1",
      "info" : {
        "title" : "${var.cluster_prefix}-API-GW",
        "version" : "2019–02–26T13:01:33Z"
      },
      "paths" : {
        "/banners" : {
          "get" : {
            "parameters" : [
              {
                "name" : "culture",
                "in" : "query",
                "required" : true,
                "schema" : {
                  "type" : "string"
                }
              },
              {
                "name" : "page",
                "in" : "query",
                "required" : false,
                "schema" : {
                  "type" : "string"
                }
              },
              {
                "name" : "limit",
                "in" : "query",
                "required" : false,
                "schema" : {
                  "type" : "string"
                }
              }
            ],
            "x-amazon-apigateway-integration" : {
              "uri" : "http://${aws_alb.alb.dns_name}:5000/api/banners",
              "httpMethod" : "GET", # integration http recive method can be GET or POST etc
              "type" : "HTTP_PROXY",
              "payloadFormatVersion" = "1.0"
            }
          },


        }
        // Second root

      }
    }
  )

  description = "${var.cluster_prefix} API Gateway"
  name        = var.cluster_prefix

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
# end create api

# #  create User resource EXAMPLE 2 STEPS
# resource "aws_api_gateway_resource" "usersResource" {
#   rest_api_id = aws_api_gateway_rest_api.orangutan_api.id
#   parent_id   = aws_api_gateway_rest_api.orangutan_api.root_resource_id # In this case, the parent id should the gateway root_resource_id.
#   path_part   = "users"
# }
# # end create User resource

# # create Card resource
# resource "aws_api_gateway_resource" "cardsResource" {
#   rest_api_id = aws_api_gateway_rest_api.orangutan_api.id
#   parent_id   = aws_api_gateway_rest_api.orangutan_api.root_resource_id
#   path_part   = "cards"
# }
# # end create Card resource

# # create sub resource for Card resource
# resource "aws_api_gateway_resource" "playCardResource" {
#   rest_api_id = aws_api_gateway_rest_api.orangutan_api.id
#   parent_id   = aws_api_gateway_resource.cardsResource.id # In this case, the parent id should be the parent aws_api_gateway_resource id.
#   path_part   = "play"
# }

# resource "aws_api_gateway_resource" "sendCardResource" {
#   rest_api_id = aws_api_gateway_rest_api.orangutan_api.id
#   parent_id   = aws_api_gateway_resource.cardsResource.id
#   path_part   = "send"
# }
# # end create sub resource for Card resource

# # create METHOD for Card send resource
# resource "aws_api_gateway_method" "MyDemoMethod" {
#   rest_api_id   = aws_api_gateway_rest_api.orangutan_api.id
#   resource_id   = aws_api_gateway_resource.sendCardResource.id
#   http_method   = "GET" # or POST
#   authorization = "NONE"
# }
# # end create METHOD for Card send resource

# # create METHOD INTEGRATION for Card send resource
# resource "aws_api_gateway_integration" "test" {
#   rest_api_id = aws_api_gateway_rest_api.orangutan_api.id
#   resource_id = aws_api_gateway_resource.sendCardResource.id
#   http_method = aws_api_gateway_method.MyDemoMethod.http_method

#   type                    = "HTTP_PROXY"
#   uri                     = "https://ip-ranges.amazonaws.com/ip-ranges.json"
#   integration_http_method = "GET" # or POST
# }

### USED to deploy the API to staging
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.orangutan_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.orangutan_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a stage for the API
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.orangutan_api.id
  stage_name    = "dev"
}

### END USED to deploy the API to staging

