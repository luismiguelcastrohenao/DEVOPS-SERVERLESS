// 1. Tabla DynamoDB para almacenar mensajes
resource "aws_dynamodb_table" "blogs" {
  name         = "blogs-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "blog_id"

  attribute {
    name = "blog_id"
    type = "N"                   # Cambiado de "S" (string) a "N" (number)
  }
}

#   //2. IAM Role for Lambdas -- Politica Customer Managed
# data "aws_iam_policy_document" "lambda_assume" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }

# # Rol de ejecución para Lambda
# resource "aws_iam_role" "lambda_role" {
#   name               = "lambda_exec_role"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
# }
#  // Asocia a uno o varios roles
#         //Útil cuando:
#             //*Querés una política centralizada y reutilizable.
#             //*Múltiples roles comparten los mismos permisos.
# resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# // Permisos demasiados amplios
# # resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
# #   role       = aws_iam_role.lambda_role.name
# #   policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
# # }

# # Política personalizada para acceso selectivo a DynamoDB
#  // crea una política independiente y reutilizable (customer-managed).
# resource "aws_iam_policy" "lambda_dynamo_custom_policy" {
#   name        = "lambda_dynamo_custom_policy"
#   description = "Permite acceso selectivo a DynamoDB para las Lambdas"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid      = "AllowGetItemForGet",
#         Effect   = "Allow",
#         Action   = "dynamodb:GetItem",
#         Resource = aws_dynamodb_table.blogs.arn
#       },
#       {
#         Sid      = "AllowPutForPost",
#         Effect   = "Allow",
#         Action   = "dynamodb:PutItem",
#         Resource = aws_dynamodb_table.blogs.arn
#       },
#       {
#         Sid      = "AllowDeleteForDelete",
#         Effect   = "Allow",
#         Action   = "dynamodb:DeleteItem",
#         Resource = aws_dynamodb_table.blogs.arn
#       }
#     ]
#   })
# }

# # Asociar la política personalizada al rol Lambda
# resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_dynamo_custom_policy.arn
# }

# -------------------------------------------------------------------------

    # 1 rol Lambda (aws_iam_role.lambda_role)
    # 1 política básica de ejecución (logs)
    # 3 políticas inline (una por Lambda):
    #   dynamodb:GetItem → para getBlogsLambda
    #   dynamodb:PutItem → para postBlogsLambda
    #   dynamodb:DeleteItem → para deleteBlogsLambda

// IAM Policy Document para getBlogsLambda
// 1. Policy de asunción (necesaria para cualquier rol Lambda)
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

// 2. Rol Lambda
# 2.1 Role para get_lambda
resource "aws_iam_role" "get_lambda_role" {
  name               = "get_lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# 2.2 Role para post_lambda
resource "aws_iam_role" "post_lambda_role" {
  name               = "post_lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# 2.3 Role para get_lambda
resource "aws_iam_role" "delete_lambda_role" {
  name               = "delete_lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

// 3. Adjuntar política básica de ejecución (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "get_logs" {
  role       = aws_iam_role.get_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "post_logs" {
  role       = aws_iam_role.post_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "delete_logs" {
  role       = aws_iam_role.delete_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##########################################################
# Políticas inline por Lambda:
##########################################################

# 4. Política para getBlogsLambda (GetItem)
      // Genera un documento de política de IAM en formato JSON para su uso con recursos 
      // que requieren documentos de política como aws_iam_policy. Ej:
      
      # {
      # 	"Version": "2012-10-17",
      # 	"Statement": [
      # 		{
      # 			"Sid": "VisualEditor0",
      # 			"Effect": "Allow",
      # 			"Action": "dynamodb:PutItem",
      # 			"Resource": "arn:aws:dynamodb:us-east-2:465731220541:table/blogs-dev"
      # 		}
      # 	]
      # }
# 4. Política para getBlogsLambda (GetItem)
data "aws_iam_policy_document" "get_policy" {
  statement {
    effect = "Allow"
    actions = ["dynamodb:GetItem"]
    resources = [aws_dynamodb_table.blogs.arn]
  }
}

resource "aws_iam_role_policy" "get_inline_policy" {
  name   = "get-blogs-inline-policy"
  role   = aws_iam_role.get_lambda_role.name
  policy = data.aws_iam_policy_document.get_policy.json
}

# 5. Política para postBlogsLambda (PutItem)
data "aws_iam_policy_document" "post_policy" {
  statement {
    effect = "Allow"
    actions = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.blogs.arn]
  }
}

resource "aws_iam_role_policy" "post_inline_policy" {
  name   = "post-blogs-inline-policy"
  role   = aws_iam_role.post_lambda_role.name
  policy = data.aws_iam_policy_document.post_policy.json
}

# 6. Política para deleteBlogsLambda (DeleteItem)
data "aws_iam_policy_document" "delete_policy" {
  statement {
    effect = "Allow"
    actions = ["dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.blogs.arn]
  }
}

resource "aws_iam_role_policy" "delete_inline_policy" {
  name   = "delete-blogs-inline-policy"
  role   = aws_iam_role.delete_lambda_role.name
  policy = data.aws_iam_policy_document.delete_policy.json
}


# // 3. Package Lambdas
# Terraform tome archivo .js, cree un .zip en la misma carpeta .iac y lo use para desplear lambda
data "archive_file" "get_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_get.mjs"
  output_path = "${path.module}/lambda_get.zip"
}

data "archive_file" "post_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_post.mjs"
  output_path = "${path.module}/lambda_post.zip"
}

data "archive_file" "delete_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_delete.mjs"
  output_path = "${path.module}/lambda_delete.zip"
}

// 4. Lambda Functions
resource "aws_lambda_function" "get" {
  function_name = "getBlogsLambda"
  filename      = data.archive_file.get_lambda.output_path
  handler       = "lambda_get.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.get_lambda_role.arn
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.blogs.id
    }
  }
}

resource "aws_lambda_function" "post" {
  function_name = "postBlogsLambda"
  filename      = data.archive_file.post_lambda.output_path
  handler       = "lambda_post.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.post_lambda_role.arn
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.blogs.id
    }
  }
}

resource "aws_lambda_function" "delete" {
  function_name = "deleteBlogsLambda"
  filename      = data.archive_file.delete_lambda.output_path
  handler       = "lambda_delete.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.delete_lambda_role.arn
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.blogs.id
    }
  }
}

// 4. API Gateway REST - Crea la instancia del API REST.
 #  Es la raíz del API, sobre ella se montarán los recursos como /blogs, /blogs/{blog_id}, etc.
resource "aws_api_gateway_rest_api" "blog_api" {
  name        = "blog-api"
  description = "Serverless Blog API"
}

# Root /blogs - Esto crea el path /blogs dentro de tu API
resource "aws_api_gateway_resource" "blogs" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_rest_api.blog_api.root_resource_id  # apunta a la raíz
  path_part   = "blogs"
}

// 4.1 Método GET /blogs - Permite invocar GET /blogs sin autenticación
resource "aws_api_gateway_method" "get_blogs" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.blogs.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integración GET con Lambda - Aquí se conecta la ruta /blogs al Lambda get
resource "aws_api_gateway_integration" "get_blogs" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.blogs.id
  http_method             = aws_api_gateway_method.get_blogs.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Modo AWS_PROXY, es decir, pasa todo el request tal cual al Lambda
  uri                     = aws_lambda_function.get.invoke_arn
}

// 4.2 Método POST /blogs 
resource "aws_api_gateway_method" "post_blogs" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.blogs.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integración POST con Lambda - Aquí se conecta la ruta /blogs al Lambda post
resource "aws_api_gateway_integration" "post_blogs" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.blogs.id
  http_method             = aws_api_gateway_method.post_blogs.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post.invoke_arn
}

# Sub-resource /blogs/{blog_id} - Crea el path dinámico con parámetro de ruta.
resource "aws_api_gateway_resource" "blog_item" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.blogs.id
  path_part   = "{blog_id}"
}

// 4.3 Método DELETE /blogs/{blog_id} - Requiere el parámetro blog_id en la URL
resource "aws_api_gateway_method" "delete_blog" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.blog_item.id
  http_method   = "DELETE"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.blog_id" = true
  }
}

resource "aws_api_gateway_integration" "delete_blog" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.blog_item.id
  http_method             = aws_api_gateway_method.delete_blog.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete.invoke_arn
  request_parameters = {
    "integration.request.path.blog_id" = "method.request.path.blog_id"
  }
}

resource "aws_lambda_permission" "apigw_lambda_get" {
  statement_id  = "InvokePermissionFromApiGatewayGetBlogsTerraform"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  //source_arn = "arn:aws:execute-api:us-east-2:465731220541:rddszkmn2k/*/GET/blogs"
  source_arn    = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.blog_api.id}/*/${aws_api_gateway_method.get_blogs.http_method}${aws_api_gateway_resource.blogs.path}"
}

resource "aws_lambda_permission" "apigw_lambda_post" {
  statement_id  = "InvokePermissionFromApiGatewayPostBlogsTerraform"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post.function_name
  principal     = "apigateway.amazonaws.com"
  //source_arn    = "arn:aws:execute-api:us-east-2:465731220541:rddszkmn2k/*/POST/blogs"
  source_arn    = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.blog_api.id}/*/${aws_api_gateway_method.post_blogs.http_method}${aws_api_gateway_resource.blogs.path}"
}

resource "aws_lambda_permission" "apigw_lambda_delete" {
  statement_id  = "InvokePermissionFromApiGatewayDeleteBlogsTerraform"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete.function_name
  principal     = "apigateway.amazonaws.com"
  //source_arn    = "arn:aws:execute-api:us-east-2:465731220541:rddszkmn2k/*/DELETE/blogs/*"  # El * al final de blogs/* es importante porque blog_id es dinámico (path parameter)
  source_arn    = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.blog_api.id}/*/${aws_api_gateway_method.delete_blog.http_method}${aws_api_gateway_resource.blog_item.path}"
}


// 5. Integración Lambda proxy
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  depends_on = [
    aws_api_gateway_integration.get_blogs,
    aws_api_gateway_integration.post_blogs,
    aws_api_gateway_integration.delete_blog
  ]
  lifecycle {
    create_before_destroy = true
  }
}

// 4.5 Despliegue y stage
resource "aws_api_gateway_stage" "dev" {
  rest_api_id      = aws_api_gateway_rest_api.blog_api.id
  deployment_id    = aws_api_gateway_deployment.deployment.id
  stage_name       = "dev"
  description      = "Development stage"
}
# Esto publica todos los endpoints bajo una URL final del tipo:
  # https://{rest_api_id}.execute-api.us-east-2.amazonaws.com/dev/blogs
