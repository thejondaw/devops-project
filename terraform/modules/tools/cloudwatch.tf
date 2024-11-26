# Удали из terraform/modules/eks/main.tf блок с созданием CloudWatch Log Group
# Убери из depends_on в EKS кластере ссылку на aws_cloudwatch_log_group.eks
# Создай новый файл terraform/modules/tools/cloudwatch.tf с обновленным кодом из артефакта




# # ================== EKS LOGS ====================== #

# # CloudWatch - Log Group - EKS Control Plane
# resource "aws_cloudwatch_log_group" "eks" {
#   name              = "/aws/eks/${data.aws_eks_cluster.cluster.name}/cluster"
#   retention_in_days = 7

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "CloudWatch"
#     Type        = "EKSLogs"
#     LogType     = "ControlPlane"
#     Retention   = "7-days"
#   }
# }

# # ================ CLOUDWATCH ALARMS ================= #

# # Metric Alarm - Node CPU High
# resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
#   alarm_name          = "${var.environment}-node-cpu-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "3"
#   metric_name        = "node_cpu_utilization"
#   namespace          = "ContainerInsights"
#   period             = "300"
#   statistic          = "Average"
#   threshold          = "80"
#   alarm_description  = "Node CPU utilization is too high"
#   alarm_actions      = [aws_sns_topic.alerts.arn]

#   dimensions = {
#     ClusterName = data.aws_eks_cluster.cluster.name
#   }

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "CloudWatch"
#     Type        = "Alarm"
#   }
# }

# # Metric Alarm - Node Memory High
# resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
#   alarm_name          = "${var.environment}-node-memory-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "3"
#   metric_name        = "node_memory_utilization"
#   namespace          = "ContainerInsights"
#   period             = "300"
#   statistic          = "Average"
#   threshold          = "80"
#   alarm_description  = "Node memory utilization is too high"
#   alarm_actions      = [aws_sns_topic.alerts.arn]

#   dimensions = {
#     ClusterName = data.aws_eks_cluster.cluster.name
#   }

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "CloudWatch"
#     Type        = "Alarm"
#   }
# }

# # Metric Alarm - RDS CPU High
# resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
#   alarm_name          = "${var.environment}-rds-cpu-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "3"
#   metric_name        = "CPUUtilization"
#   namespace          = "AWS/RDS"
#   period             = "300"
#   statistic          = "Average"
#   threshold          = "80"
#   alarm_description  = "RDS CPU utilization is too high"
#   alarm_actions      = [aws_sns_topic.alerts.arn]

#   dimensions = {
#     DBClusterIdentifier = "${var.environment}-aurora-cluster"
#   }

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "CloudWatch"
#     Type        = "Alarm"
#   }
# }

# # Billing Alarm
# resource "aws_cloudwatch_metric_alarm" "billing" {
#   alarm_name          = "${var.environment}-monthly-billing"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "1"
#   metric_name        = "EstimatedCharges"
#   namespace          = "AWS/Billing"
#   period             = "21600" # 6 hours
#   statistic          = "Maximum"
#   threshold          = "100"  # USD
#   alarm_description  = "Monthly AWS charges exceeded 100 USD"
#   alarm_actions      = [aws_sns_topic.alerts.arn]

#   dimensions = {
#     Currency = "USD"
#   }

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "CloudWatch"
#     Type        = "Alarm"
#   }
# }

# # ================== SNS TOPIC ==================== #

# # SNS Topic - Alerts
# resource "aws_sns_topic" "alerts" {
#   name = "${var.environment}-monitoring-alerts"

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "SNS"
#   }
# }

# # SNS Topic Policy
# resource "aws_sns_topic_policy" "alerts" {
#   arn = aws_sns_topic.alerts.arn

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudwatch.amazonaws.com"
#         }
#         Action   = "SNS:Publish"
#         Resource = aws_sns_topic.alerts.arn
#       }
#     ]
#   })
# }

# # ============= CONTAINER INSIGHTS ================ #

# # Enable Container Insights
# resource "aws_eks_addon" "container_insights" {
#   cluster_name = data.aws_eks_cluster.cluster.name
#   addon_name   = "amazon-cloudwatch-observability"

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "EKS"
#     Component   = "ContainerInsights"
#   }
# }

# # Log Group - Container Insights
# resource "aws_cloudwatch_log_group" "container_insights" {
#   name              = "/aws/containerinsights/${data.aws_eks_cluster.cluster.name}/application"
#   retention_in_days = 7

#   tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Service     = "CloudWatch"
#     Type        = "ContainerLogs"
#   }
# }