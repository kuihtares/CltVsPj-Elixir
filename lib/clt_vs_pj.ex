defmodule CltVsPj do

  @inss_brackets [
    {0, 1518.00, 0.075},
    {1518.01, 2793.88, 0.09},
    {2793.89, 4190.83, 0.12},
    {4190.84, 8157.41, 0.14}
  ]

  # IRRF brackets (2025) - monthly
  @irrf_brackets [
    {0, 2259.20, 0.0, 0},
    {2259.21, 2826.65, 0.075, 169.44},
    {2826.66, 3751.05, 0.15, 381.44},
    {3751.06, 4664.68, 0.225, 662.77},
    {4664.69, :infinity, 0.275, 896.00}
  ]

  @irrf_deduction_per_dependent 189.59

  defp format_currency(value) do
    :erlang.float_to_binary(value * 1.0, decimals: 2)
  end

  defp parse_benefit(""), do: 0.0
  defp parse_benefit(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error ->
        case Integer.parse(value) do
          {num, _} -> num * 1.0
          :error -> 0.0
        end
    end
  end

  def user_input do
    IO.puts("\n=== CLT vs PJ Calculator (2025) ===\n")

    salary = IO.gets("Enter your CLT salary: ")
    |> String.trim()
    |> parse_benefit()

    IO.puts("\nEnter your monthly benefits (press Enter to skip):")

    health = IO.gets("Health insurance (R$): ")
    |> String.trim()
    |> parse_benefit()

    transport = IO.gets("Transportation voucher (R$): ")
    |> String.trim()
    |> parse_benefit()

    meal = IO.gets("Meal voucher (R$): ")
    |> String.trim()
    |> parse_benefit()

    food = IO.gets("Food voucher (R$): ")
    |> String.trim()
    |> parse_benefit()

    benefits = %{health: health, transport: transport, meal: meal, food: food}
    total_benefits = calculate_clt_benefits(benefits)

    dependents = IO.gets("\nNumber of dependents for IR: ")
    |> String.trim()
    |> parse_benefit()
    |> trunc()

    IO.puts("\n=== CALCULATING CLT SCENARIO ===\n")

    # Cálculos CLT
    monthly_salary = salary
    inss = calculate_inss(monthly_salary)
    irrf = calculate_irrf(monthly_salary, dependents)
    fgts = calculate_fgts(monthly_salary)
    vacation = calculate_vacation(monthly_salary)
    vacation_bonus = monthly_salary / 3  # 1/3 de férias
    thirteenth = calculate_13th_salary(monthly_salary)

    # INSS sobre 1/3 de férias e 13º
    inss_vacation_bonus = calculate_inss(vacation_bonus)
    inss_13th = calculate_inss(thirteenth)

    # IRRF sobre 13º (sem dependentes pois é calculado separadamente)
    irrf_13th = calculate_irrf(thirteenth, 0)

    annual_gross_clt = (monthly_salary * 12) + vacation + thirteenth
    annual_inss = (inss * 12) + inss_vacation_bonus + inss_13th
    annual_irrf = (irrf * 12) + irrf_13th
    annual_fgts = fgts * 12

    net_monthly_clt = monthly_salary - inss - irrf
    net_monthly_with_benefits = net_monthly_clt + total_benefits

    annual_benefits = total_benefits * 12
    total_annual_net_clt = annual_gross_clt - annual_inss - annual_irrf - annual_fgts + annual_benefits

    IO.puts("Monthly Salary: R$ #{format_currency(monthly_salary)}")
    IO.puts("INSS (monthly): R$ #{format_currency(inss)}")
    IO.puts("IRRF (monthly): R$ #{format_currency(irrf)}")
    if dependents > 0 do
      IO.puts("  Dependents: #{dependents}")
    end
    IO.puts("FGTS (monthly): R$ #{format_currency(fgts)}")
    IO.puts("Net Monthly (salary only): R$ #{format_currency(net_monthly_clt)}")
    IO.puts("\nMonthly Benefits:")
    if total_benefits > 0 do
      IO.puts("  Health: R$ #{format_currency(benefits.health)}")
      IO.puts("  Transport: R$ #{format_currency(benefits.transport)}")
      IO.puts("  Meal: R$ #{format_currency(benefits.meal)}")
      IO.puts("  Food: R$ #{format_currency(benefits.food)}")
      IO.puts("  Total Benefits: R$ #{format_currency(total_benefits)}")
    else
      IO.puts("  No benefits")
    end
    IO.puts("Net Monthly (with benefits): R$ #{format_currency(net_monthly_with_benefits)}")
    IO.puts("\nAnnual Benefits:")
    IO.puts("  Vacation (salary + 1/3): R$ #{format_currency(vacation)}")
    IO.puts("  13th Salary: R$ #{format_currency(thirteenth)}")
    IO.puts("  Annual Benefits (12 months): R$ #{format_currency(annual_benefits)}")
    IO.puts("  Total Annual Net: R$ #{format_currency(total_annual_net_clt)}")

    IO.puts("\n=== CALCULATING EQUIVALENT PJ ===\n")

    # Para PJ: precisa ganhar o equivalente líquido anual do CLT
    pj_tax_rate = 0.17

    # Salário PJ necessário para igualar o líquido anual CLT
    required_pj_annual = total_annual_net_clt / (1 - pj_tax_rate)
    required_pj_monthly = required_pj_annual / 12

    pj_taxes = required_pj_annual * pj_tax_rate

    IO.puts("Required PJ Monthly: R$ #{format_currency(required_pj_monthly)}")
    IO.puts("Required PJ Annual: R$ #{format_currency(required_pj_annual)}")
    IO.puts("PJ Taxes (17%): R$ #{format_currency(pj_taxes)}")
    IO.puts("PJ Net Annual: R$ #{format_currency(required_pj_annual - pj_taxes)}")

    IO.puts("\n=== COMPARISON ===\n")
    difference = required_pj_monthly - monthly_salary
    percentage = (difference / monthly_salary) * 100

    IO.puts("CLT Monthly: R$ #{format_currency(monthly_salary)}")
    IO.puts("PJ Monthly Needed: R$ #{format_currency(required_pj_monthly)}")
    IO.puts("Difference: R$ #{format_currency(difference)} (+#{format_currency(percentage)}%)")
  end

  def calculate_vacation(salary) when is_number(salary) and salary > 0 do
    salary + (salary / 3)
  end

  def calculate_vacation(_), do: 0.0

  def calculate_13th_salary(salary) when is_number(salary) and salary > 0 do
    salary
  end

  def calculate_13th_salary(_), do: 0.0

  def calculate_inss(salary) when is_number(salary) and salary > 0 do
    @inss_brackets
    |> Enum.reduce({salary, 0}, &apply_bracket/2)
    |> elem(1)
  end

  def calculate_inss(_), do: 0.0

  def calculate_irrf(salary, dependents \\ 0)

  def calculate_irrf(salary, dependents) when is_number(salary) and salary > 0 do
    inss = calculate_inss(salary)
    taxable_base = salary - inss - (dependents * @irrf_deduction_per_dependent)

    with true <- taxable_base > 0,
         {_min, _max, rate, deduction} <- find_irrf_bracket(taxable_base) do
      max((taxable_base * rate) - deduction, 0.0)
    else
      _ -> 0.0
    end
  end

  def calculate_irrf(_, _), do: 0.0

  defp find_irrf_bracket(taxable_base) do
    Enum.find(@irrf_brackets, fn
      {min, max, _rate, _ded} when is_number(max) -> taxable_base >= min and taxable_base <= max
      {min, :infinity, _rate, _ded} -> taxable_base >= min
      _ -> false
    end)
  end

  defp apply_bracket({min, max, rate}, {remaining_salary, accumulated_tax})
       when remaining_salary > 0 do
    taxable_amount = min(remaining_salary, max - min + 0.01)
    tax = taxable_amount * rate

    {remaining_salary - taxable_amount, accumulated_tax + tax}
  end

  defp apply_bracket(_, {remaining_salary, accumulated_tax}) do
    {remaining_salary, accumulated_tax}
  end

  def calculate_fgts(salary) when is_number(salary) and salary > 0 do
    salary * 0.08
  end

  def calculate_fgts(_), do: 0.0

  def calculate_clt_benefits(benefits_map) when is_map(benefits_map) do
    Map.get(benefits_map, :health, 0) +
    Map.get(benefits_map, :transport, 0) +
    Map.get(benefits_map, :meal, 0) +
    Map.get(benefits_map, :food, 0)
  end

  def calculate_clt_benefits(_), do: 0.0

  def calculate_discount(salary) when is_number(salary)  and salary > 0 do
      Float.round(Enum.sum([calculate_inss(salary), calculate_fgts(salary)]), 2)
  end

end
