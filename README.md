
# Exchange PayPay

Tech Assigment from PayPay to iOS role

![](https://raw.githubusercontent.com/JamysonFreirejf/Exchange/master/Screenshots/Screenshot%202024-04-09%20at%2010.44.05.png)

# Functional Requirements

- The required data must be fetched from the open exchange rates service.
https://openexchangerates.org/
- The required data must be persisted locally to permit the application to be used
offline after data has been fetched.
- In order to limit bandwidth usage, the required data can be refreshed from the API no
more frequently than once every 30 minutes.
- The user must be able to select a currency from a list of currencies provided by open
exchange rates.
- The user must be able to enter the desired amount for the selected currency.
- The user must then be shown a list showing the desired amount in the selected
currency converted into amounts in each currency provided by open exchange rates.
- If exchange rates for the selected currency are not available via open
exchange rates, perform the conversions on the app side.
- When converting, floating point errors are acceptable.
- The project must contain unit tests that ensure correct operation.

# Note

Please note that the below points are definitely needed to pass.
### 1. Write the Unit Test
We consider this as one of important point to evaluate your code.
Without any test, it cannot guarantee product quality.
So writing test code is important criteria for us.

### 2. Use a free account (paid account is not acceptable)
To treat every candidates fairly, a paid account is not acceptable.
We expect that you invent own way to exchange any currencies using a free account
which support only dollar.

# Instructions

Run ```pod install``` before starting the project
