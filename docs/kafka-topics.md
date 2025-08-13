# Topics Documentation:
## 1. purchases
Purpose: Stores incoming purchase transactions from users.

Key Schema: User ID (string or UUID) representing the purchaser.

Value Schema:
```
{
    "transactionId": string,
    "timestamp": ISO8601 string,
    "amount": number,
    "items": array of item objects,
    "paymentMethod": string
}
```

## 2. points-calculated
Purpose: Contains the output of points processing, reflecting points awarded for purchases.

Key Schema: User ID (string or UUID).
Value Schema:
```
{
    "transactionId": string,
    "pointsAwarded": number,
    "totalPoints": number,
    "timestamp": ISO8601 string
}
```

## 3. points-redeemed
Purpose: Records redemption requests where users redeem their points.

Key Schema: User ID (string or UUID).

Value Schema:
```
{
    "redemptionId": string,
    "pointsRedeemed": number,
    "rewardType": string,
    "timestamp": ISO8601 string
}
```

## 4. fraud-alerts
Purpose: Captures suspicious activity or potential fraud detected in the system.

Key Schema: Alert ID (string or UUID).

Value Schema:
```
{
    "userId": string,
    "transactionId": string (optional),
    "alertType": string,
    "description": string,
    "timestamp": ISO8601 string
}
```
