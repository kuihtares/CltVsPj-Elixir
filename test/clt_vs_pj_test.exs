defmodule CltVsPjTest do
  use ExUnit.Case
  doctest CltVsPj

  test "vacation calculation" do
    assert CltVsPj.calculate_vacation(3000) == 4000.0
    assert CltVsPj.calculate_vacation(1500) == 2000.0

    assert CltVsPj.calculate_vacation(0) == 0.0
    assert CltVsPj.calculate_vacation(-100) == 0.0
  end

  test "calculation of 13th salary" do
    assert CltVsPj.calculate_13th_salary(3000) == 3000.0

    assert CltVsPj.calculate_13th_salary(0) == 0.0
    assert CltVsPj.calculate_13th_salary(-500) == 0.0
    assert CltVsPj.calculate_13th_salary("text") == 0.0
    assert CltVsPj.calculate_13th_salary(nil) == 0.0
    assert CltVsPj.calculate_13th_salary(2500) == 2500.0
    assert CltVsPj.calculate_13th_salary(:test) == 0.0
  end

  test "calculation of progressive INSS" do
    # Test in first bracket (up to R$ 1,518.00) - 2025
    assert_in_delta CltVsPj.calculate_inss(1000.00), 75.00, 0.01

    # Test exactly at the first bracket limit
    assert_in_delta CltVsPj.calculate_inss(1518.00), 113.85, 0.01

    # Test in second bracket (R$ 2,000.00)
    # First bracket: R$ 1,518.00 * 0.075 = R$ 113.85
    # Second bracket: (R$ 2,000.00 - R$ 1,518.01) * 0.09 = R$ 481.99 * 0.09 = R$ 43.38
    # Total: R$ 113.85 + R$ 43.38 = R$ 157.23
    assert_in_delta CltVsPj.calculate_inss(2000.00), 157.23, 0.01

    # Test in third bracket (R$ 3,000.00)
    # First bracket: R$ 1,518.00 * 0.075 = R$ 113.85
    # Second bracket: (R$ 2,793.88 - R$ 1,518.01) * 0.09 = R$ 1,275.87 * 0.09 = R$ 114.83
    # Third bracket: (R$ 3,000.00 - R$ 2,793.89) * 0.12 = R$ 206.11 * 0.12 = R$ 24.73
    # Total: R$ 113.85 + R$ 114.83 + R$ 24.73 = R$ 253.41
    assert_in_delta CltVsPj.calculate_inss(3000.00), 253.41, 0.01

    # Test above ceiling (R$ 8,500.00 - should calculate only up to ceiling of R$ 8,157.41)
    max_inss = CltVsPj.calculate_inss(8157.41)
    assert_in_delta CltVsPj.calculate_inss(8500.00), max_inss, 0.01

    # Test with invalid input
    assert CltVsPj.calculate_inss(0) == 0.0
    assert CltVsPj.calculate_inss(-100) == 0.0
    assert CltVsPj.calculate_inss("text") == 0.0
  end

  test "calculation of FGTS" do
    assert CltVsPj.calculate_fgts(3000) == 240.0
    assert CltVsPj.calculate_fgts(1500) == 120.0
    assert CltVsPj.calculate_fgts(0) == 0.0
    assert CltVsPj.calculate_fgts(-100) == 0.0
  end

  test "discount calculation" do
    total = CltVsPj.calculate_discount(5000)
    # With 2025 table: INSS R$ 509.60 + FGTS R$ 400.00 = R$ 909.60
    assert total == 909.60
  end
end
