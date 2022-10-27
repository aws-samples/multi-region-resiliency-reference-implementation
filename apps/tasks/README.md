# ECS Task Control
## Prerequisites
pip install -r requirements.txt
## List all tasks on all clusters
```shell
python ecs_tasks.py --region us-east-1 --action list
```

## Stop all tasks on all clusters
```shell
python ecs_tasks.py --region us-east-1 --action stop-all
```

## Start all tasks on all clusters
```shell
python ecs_tasks.py --region us-east-1 --action start-all
```

## Start all tasks on all clusters all regions
```shell
python ecs_tasks.py --action start-all-regions
```
## stop all tasks on all clusters all regions
```shell
python ecs_tasks.py --action stop-all-regions
```
## Start trade-matching tasks
```shell
python ecs_tasks.py --region us-east-1 --action start-trade-matching
```

## Start settlement tasks
```shell
python ecs_tasks.py --region us-east-1 --action start-settlement
```

## Clean All - Warning!
```shell
python ecs_tasks.py --region us-east-1 --action clean
```