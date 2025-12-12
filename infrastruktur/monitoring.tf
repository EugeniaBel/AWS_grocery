# 1. Create the SNS Topic for sending notifications
resource "aws_sns_topic" "alerts" {
  name = "grocerymate-cpu-high-alert"
}

# 2. Create the Email Subscription for the SNS Topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"

  # Subscribing the user's email to the topic
  endpoint  = var.alert_email
}

# 3. Create the CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "grocerymate-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120    # Check every 2 minutes (120 seconds)
  statistic           = "Average"
  threshold           = 80     # Trigger alarm if CPU is above 80%
  alarm_description   = "Alarm to notify when EC2 CPU usage exceeds 80%"
  actions_enabled     = true

  # Action: Send a message to the SNS Topic when the ALARM state is reached
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    # Targeting the Instance ID of the EC2 resource named "web" from main.tf
    InstanceId = aws_instance.web.id
  }
}