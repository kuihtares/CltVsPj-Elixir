defmodule CltVsPj do

  # Faixas do INSS (2024) - valores atualizados
  @inss_brackets [
    {0, 1412.00, 0.075},
    {1412.01, 2666.68, 0.09},
    {2666.69, 4000.03, 0.12},
    {4000.04, 7786.02, 0.14}
  ]

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
    IO.puts("\n=== CLT vs PJ Calculator (2024) ===\n")

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

    IO.puts("\n=== CALCULATING CLT SCENARIO ===\n")

    # Cálculos CLT
    monthly_salary = salary
    inss = calculate_inss(monthly_salary)
    fgts = calculate_fgts(monthly_salary)
    vacation = calculate_vacation(monthly_salary)
    thirteenth = calculate_13th_salary(monthly_salary)

    # Total anual CLT (12 meses + férias + 13º - descontos anuais)
    annual_gross_clt = (monthly_salary * 12) + vacation + thirteenth
    annual_inss = inss * 13  # 12 meses + 13º
    annual_fgts = fgts * 13  # 12 meses + 13º

    net_monthly_clt = monthly_salary - inss - fgts
    net_monthly_with_benefits = net_monthly_clt + total_benefits

    annual_benefits = total_benefits * 12
    total_annual_net_clt = annual_gross_clt - annual_inss - annual_fgts + annual_benefits

    IO.puts("Monthly Salary: R$ #{format_currency(monthly_salary)}")
    IO.puts("INSS (monthly): R$ #{format_currency(inss)}")
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
    IO.puts("  13th Salary (2x): R$ #{format_currency(thirteenth)}")
    IO.puts("  Annual Benefits (12 months): R$ #{format_currency(annual_benefits)}")
    IO.puts("  Total Annual Net: R$ #{format_currency(total_annual_net_clt)}")

    IO.puts("\n=== CALCULATING EQUIVALENT PJ ===\n")

    # Para PJ: precisa ganhar o equivalente líquido anual do CLT
    # Considerando impostos PJ (Simples Nacional ~6% + INSS ~11% = ~17%)
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
    salary * 2
  end

  def calculate_13th_salary(_), do: 0.0

  def calculate_inss(salary) when is_number(salary) and salary > 0 do
    @inss_brackets
    |> Enum.reduce({salary, 0}, &apply_bracket/2)
    |> elem(1)
  end

  def calculate_inss(_), do: 0.0

  defp apply_bracket({min, max, rate}, {remaining_salary, accumulated_tax})
       when remaining_salary > 0 do
    taxable_amount = min(remaining_salary, max - min + 0.01)
    tax = taxable_amount * rate

    {remaining_salary - taxable_amount, accumulated_tax + tax}
  end

  defp apply_bracket(_, {remaining_salary, accumulated_tax}) do
    {remaining_salary, accumulated_tax}
  end

  def tax_scenario(salary) when is_number(salary) do
    case salary do
      s when s <= 1412.00 ->
        {:primeira_faixa, "Apenas primeira faixa (7,5%)", calculate_inss(s)}

      s when s <= 2666.68 ->
        {:segunda_faixa, "Primeira e segunda faixas (7,5% + 9%)", calculate_inss(s)}

      s when s <= 4000.03 ->
        {:terceira_faixa, "Três primeiras faixas (7,5% + 9% + 12%)", calculate_inss(s)}

      s when s <= 7786.02 ->
        {:quarta_faixa, "Todas as faixas (7,5% + 9% + 12% + 14%)", calculate_inss(s)}

      s when s > 7786.02 ->
        {:teto_inss, "Acima do teto do INSS", calculate_inss(7786.02)}

      _ ->
        {:erro, "Salário inválido", 0.0}
    end
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
