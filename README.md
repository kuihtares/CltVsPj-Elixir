# CLT vs PJ Calculator

A comprehensive Brazilian employment comparison calculator built with Elixir. This tool helps professionals understand the financial differences between working as a CLT (Consolidated Labor Laws) employee versus a PJ (Legal Entity) contractor in Brazil.

## Overview

This calculator provides detailed comparisons between CLT employment and PJ contracting by computing:

- Monthly and annual net income for CLT workers
- All mandatory deductions (INSS, IRRF, FGTS)
- Employment benefits (health insurance, meal vouchers, transportation, etc.)
- Vacation pay with constitutional bonus (salary + 1/3)
- 13th salary payments
- Equivalent PJ monthly rate needed to match CLT total compensation

## Features

### CLT Calculations
- **INSS (Social Security)**: Progressive tax calculation based on 2025 brackets
- **IRRF (Income Tax)**: Progressive withholding tax with dependent deductions
- **FGTS (Severance Fund)**: 8% employer contribution
- **Vacation Pay**: Full salary plus 1/3 constitutional bonus with INSS deduction
- **13th Salary**: Annual bonus with separate INSS and IRRF calculations
- **Benefits**: Health insurance, transportation, meal, and food vouchers

### PJ Calculations
- Tax rate estimation (default 17% for Simples Nacional)
- Required gross income to match CLT net compensation
- Annual and monthly rate comparisons

### Tax Tables (2025)

**INSS Brackets:**
- Up to R$ 1,518.00: 7.5%
- R$ 1,518.01 to R$ 2,793.88: 9%
- R$ 2,793.89 to R$ 4,190.83: 12%
- R$ 4,190.84 to R$ 8,157.41: 14%

**IRRF Brackets:**
- Up to R$ 2,259.20: Exempt
- R$ 2,259.21 to R$ 2,826.65: 7.5% (R$ 169.44 deduction)
- R$ 2,826.66 to R$ 3,751.05: 15% (R$ 381.44 deduction)
- R$ 3,751.06 to R$ 4,664.68: 22.5% (R$ 662.77 deduction)
- Above R$ 4,664.69: 27.5% (R$ 896.00 deduction)

Dependent deduction: R$ 189.59 per dependent

## Installation

### Prerequisites
- Elixir 1.19 or higher
- Erlang/OTP 28 or higher

### Setup

Clone the repository:
```bash
git clone https://github.com/kuihtares/CltVsPj-Elixir.git
cd CltVsPj-Elixir
```

Install dependencies:
```bash
mix deps.get
```

Compile the project:
```bash
mix compile
```

## Usage

### Interactive Mode

Run the interactive calculator:
```bash
iex -S mix
```

Then execute:
```elixir
CltVsPj.user_input()
```

The calculator will prompt for:
1. Monthly CLT salary
2. Monthly benefits (health, transportation, meal, food vouchers)
3. Number of dependents for income tax calculation

### Programmatic Usage

Use individual calculation functions:

```elixir
# Calculate INSS
CltVsPj.calculate_inss(5000.00)
# => 509.60

# Calculate IRRF with dependents
CltVsPj.calculate_irrf(5000.00, 2)
# => 262.25

# Calculate FGTS
CltVsPj.calculate_fgts(5000.00)
# => 400.00

# Calculate vacation pay
CltVsPj.calculate_vacation(5000.00)
# => 6666.67

# Calculate 13th salary
CltVsPj.calculate_13th_salary(5000.00)
# => 5000.00
```

## Testing

Run the test suite:
```bash
mix test
```

Run with coverage:
```bash
mix test --cover
```

The project includes comprehensive test coverage for:
- INSS progressive calculations
- IRRF calculations with various dependent scenarios
- Vacation pay computations
- 13th salary calculations
- FGTS calculations
- Benefit aggregations

## Example Output

```
=== CLT vs PJ Calculator (2025) ===

Enter your CLT salary: 5000

Enter your monthly benefits (press Enter to skip):
Health insurance (R$): 1000
Transportation voucher (R$): 
Meal voucher (R$): 300
Food voucher (R$): 

Number of dependents for IR: 0

=== CALCULATING CLT SCENARIO ===

Monthly Salary: R$ 5000.00
INSS (monthly): R$ 509.60
IRRF (monthly): R$ 347.57
FGTS (monthly): R$ 400.00
Net Monthly (salary only): R$ 4142.83

Monthly Benefits:
  Health: R$ 1000.00
  Transport: R$ 0.00
  Meal: R$ 300.00
  Food: R$ 0.00
  Total Benefits: R$ 1300.00
Net Monthly (with benefits): R$ 5442.83

Annual Benefits:
  Vacation (salary + 1/3): R$ 6666.67
  13th Salary: R$ 5000.00
  Annual Benefits (12 months): R$ 15600.00
  Total Annual Net: R$ 71196.26

=== CALCULATING EQUIVALENT PJ ===

Required PJ Monthly: R$ 7148.22
Required PJ Annual: R$ 85778.63
PJ Taxes (17%): R$ 14582.37
PJ Net Annual: R$ 71196.26

=== COMPARISON ===

CLT Monthly: R$ 5000.00
PJ Monthly Needed: R$ 7148.22
Difference: R$ 2148.22 (+42.96%)
```

## Project Structure

```
CltVsPj-Elixir/
├── lib/
│   └── clt_vs_pj.ex          # Main calculator module
├── test/
│   ├── clt_vs_pj_test.exs    # Core function tests
│   ├── irrf_test.exs         # IRRF calculation tests
│   └── test_helper.exs       # Test configuration
├── mix.exs                    # Project configuration
└── README.md                  # This file
```

## Technical Details

### Architecture
- Pure functional implementation with pattern matching
- Progressive tax bracket calculations using reduce operations
- Guard clauses for input validation
- Default parameter support for optional inputs

### Key Algorithms
- **INSS Calculation**: Progressive bracket application with accumulation
- **IRRF Calculation**: Taxable base computation with dependent deductions
- **Bracket Matching**: Pattern matching with guard clauses for range checking

## Limitations

- PJ tax rate is simplified (fixed 17%)
- Does not account for specific Simples Nacional annexes (I-V)
- FGTS withdrawal scenarios not modeled
- Severance payments (40% FGTS fine) not included
- Does not model unemployment insurance eligibility

## Contributing

Contributions are welcome. Please ensure all tests pass before submitting pull requests:

```bash
mix test
mix format
```

## License

This project is available for educational and personal use.

## Disclaimer

This calculator provides estimates for educational purposes. Tax calculations may vary based on individual circumstances. Consult a certified accountant for professional financial advice.

