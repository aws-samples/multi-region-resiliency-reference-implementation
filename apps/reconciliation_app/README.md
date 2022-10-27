# Reconciliation App
Set the type of reconciliation and the region to invoke it.

## Prerequisites
Virtual environment:
```bash
python -m venv .venv
```

```bash
source .venv/bin/activate
```
```bash
pip install -r src/requirements.txt 
```
## Help
```bash
python src/main.py --help
```

## Running the app for Trades Reconciliation
To execute this app run the below:
example1: InboundIngress
```bash
python src/main.py --reconciliation="InboundIngress" --region=us-east-1
```
example2: IngressCore
```bash
python src/main.py --reconciliation="IngressCore" --region=us-east-1
```
example3: CoreEgress
```bash
python src/main.py --reconciliation="CoreEgress" --region=us-east-1
```
example4: EgressOutbound
```bash
python src/main.py --reconciliation="EgressOutbound" --region=us-east-1
```
example5: OutboundSettlementInbound
```bash
python src/main.py --reconciliation="OutboundSettlementInbound" --region=us-east-1
```

## Running the app for Settlement Reconciliation
example1: SettlementInboundIngress
```bash
python src/main.py --reconciliation="SettlementInboundIngress" --region=us-east-1
```
example2: SettlementIngressCore
```bash
python src/main.py --reconciliation="SettlementIngressCore" --region=us-east-1
```
example3: SettlementCoreEgress
```bash
python src/main.py --reconciliation="SettlementCoreEgress" --region=us-east-1
```
example4: SettlementEgressOutbound
```bash
python src/main.py --reconciliation="SettlementEgressOutbound" --region=us-east-1
```
example5: SettlementOutboundTradeInbound
```bash
python src/main.py --reconciliation="SettlementOutboundSettlementInbound" --region=us-east-1
```
