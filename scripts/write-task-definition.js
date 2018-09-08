console.log(process.env);

let taskDefinition = {
    "volumes": [],
    "family": "webcaptioner-" + process.env.CI_ENVIRONMENT_SLUG,
    "executionRoleArn": "REMOVED",
    "networkMode": "awsvpc",
    "containerDefinitions": [
      {
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/webcaptioner",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        },
        "portMappings": [
          {
            "hostPort": 8080,
            "protocol": "tcp",
            "containerPort": 8080
          }
        ],
        "cpu": 0,
        "memoryReservation": 300,
        "volumesFrom": [],
        "image": "REMOVED:" + process.env.CI_ENVIRONMENT_SLUG,
        "name": "webcaptioner",
        "environment": [
          {
            "name": "HUGO_BASE_URL",
            "value": "https://staging.webcaptioner.com"
          },
          {
            "name": "SENTRY_SECURITY_TOKEN",
            "value": "ba5a6c5c501f11e8aab94201c0a8d03b"
          }
        ]
      }
    ]
  };

console.log(JSON.stringify(taskDefinition));