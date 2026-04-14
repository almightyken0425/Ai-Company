import pandas as pd
import os

# ==========================================
# Configuration: File Paths
# ==========================================
# Input File (Source of Truth — defined in no1_production_management/no4_project_management)
INPUT_FILE = os.path.join('..', '..', 'no1_production_management', 'no4_project_management', 'no2_module_role_points.csv')

# Output Files
OUTPUT_FILE_ROLE_SUMMARY = 'no4_3_equity_summary_by_role.csv'
OUTPUT_FILE_COMPONENT_SUMMARY = 'no4_4_equity_summary_by_module.csv'
OUTPUT_FILE_CONSISTENCY = 'no4_5_equity_consistency_analysis.csv'

# Base Directory (Current Script Directory)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Full Paths
input_path = os.path.join(BASE_DIR, INPUT_FILE)
output_path_role_summary = os.path.join(BASE_DIR, OUTPUT_FILE_ROLE_SUMMARY)
output_path_component_summary = os.path.join(BASE_DIR, OUTPUT_FILE_COMPONENT_SUMMARY)
output_path_consistency = os.path.join(BASE_DIR, OUTPUT_FILE_CONSISTENCY)

# Tier Definitions
TIERS = [
    {
        'name': 'Tier 0 (Local)', 'price_mo': '$0', 'price_yr': '$0',
        'modules': ['Accounting App'], 'is_tier_0': True
    },
    {
        'name': 'Tier 1 (Cloud)', 'price_mo': '$30', 'price_yr': '$360',
        'modules': ['Accounting App'], 'is_tier_0': False
    },
    {
        'name': 'Tier 2 (Management)', 'price_mo': '$90', 'price_yr': '$900',
        'modules': ['Accounting App', 'Web Console'], 'is_tier_0': False
    },
    {
        'name': 'Tier 3 (Intelligence)', 'price_mo': '$140', 'price_yr': '$1,400',
        'modules': ['Accounting App', 'Web Console', 'AI Advisor'], 'is_tier_0': False
    },
    {
        'name': 'Tier B (Enterprise)', 'price_mo': '$500+', 'price_yr': '$6,000+',
        'modules': ['Accounting App', 'Web Console', 'AI Advisor', 'Macro Data'], 'is_tier_0': False
    }
]

# ==========================================
# Main Logic
# ==========================================

def parse_int(value):
    """Helper to parse currency/number strings to int."""
    if pd.isna(value) or value == '':
        return 0
    if isinstance(value, (int, float)):
        return int(value)
    try:
        return int(str(value).replace(',', '').replace('$', '').replace('+', '').strip())
    except ValueError:
        return 0

def main():
    print(f"Reading input from: {input_path}")
    
    # 1. Load Data
    try:
        df = pd.read_csv(input_path)
    except FileNotFoundError:
        print(f"Error: Input file not found at {input_path}")
        return

    # Clean up column names (strip whitespace)
    df.columns = df.columns.str.strip()
    
    # Ensure numeric columns are actually numeric
    df['Construction Points'] = df['Construction Points'].apply(parse_int)
    df['Operation Points'] = df['Operation Points'].apply(parse_int)

    # Calculate Total Construction Points for percentages
    total_construction_points = df['Construction Points'].sum()
    print(f"Total Construction Points: {total_construction_points}")

    # ==========================================
    # Task 1: Generate equity_summary_by_role.csv
    # Group by Role AND Product
    # ==========================================
    print("Generating equity_summary_by_role.csv...")
    
    # Group by Role and Module
    role_module_summary = df.groupby(['Module', 'Role'])[['Construction Points', 'Operation Points']].sum().reset_index()
    
    # Sort by Module, then Construction Points descending, then Operation Points descending
    role_module_summary = role_module_summary.sort_values(['Module', 'Construction Points', 'Operation Points'], ascending=[False, False, False])
    
    # Calculate per-module totals for percentages
    role_module_summary['Construction_Total_By_Module'] = role_module_summary.groupby('Module')['Construction Points'].transform('sum')
    role_module_summary['Operation_Total_By_Module'] = role_module_summary.groupby('Module')['Operation Points'].transform('sum')
    
    # Calculate percentages per module (avoid division by zero)
    role_module_summary['Construction_%_by_Module'] = role_module_summary.apply(
        lambda x: f"{(x['Construction Points'] / x['Construction_Total_By_Module'] * 100):.1f}%" if x['Construction_Total_By_Module'] > 0 else "0.0%", axis=1
    )
    role_module_summary['Operation_%_by_Module'] = role_module_summary.apply(
        lambda x: f"{(x['Operation Points'] / x['Operation_Total_By_Module'] * 100):.1f}%" if x['Operation_Total_By_Module'] > 0 else "0.0%", axis=1
    )
    
    # Calculate overall construction percentage
    if total_construction_points == 0:
        total_construction_points = 1
    role_module_summary['Percentage'] = (role_module_summary['Construction Points'] / total_construction_points * 100).map('{:.1f}%'.format)
    role_module_summary['Man Months'] = (role_module_summary['Construction Points'] / 2000).map('{:.1f} 人月'.format)
    role_module_summary['Op Hours'] = (role_module_summary['Operation Points'] / 200).map('{:.1f}h'.format)
    
    # Build output rows
    output_rows_role_summary = []
    output_rows_role_summary.append(['產品模組', '角色', '施工價值pt', '維運價值pt', '模組施工%', '模組維護%', '施工工時/次', '維護工時/月'])

    for _, row in role_module_summary.iterrows():
        output_rows_role_summary.append([
            row['Module'],
            f"**{row['Role']}**",
            f"{row['Construction Points']:,}",
            f"{row['Operation Points']:,}",
            row['Construction_%_by_Module'],
            row['Operation_%_by_Module'],
            row['Man Months'],
            row['Op Hours']
        ])
        
    # Total Row
    total_mm = total_construction_points / 2000
    total_ops_points = df['Operation Points'].sum()
    total_op_hours = total_ops_points / 200
    output_rows_role_summary.append([
        "**總計**",
        "",
        f"**{total_construction_points:,}**",
        f"**{total_ops_points:,}**",
        "",
        "",
        f"**{total_mm:.1f} 人月**",
        f"**{total_op_hours:.1f}h**"
    ])
    
    pd.DataFrame(output_rows_role_summary).to_csv(output_path_role_summary, index=False, header=False, encoding='utf-8-sig')


    # ==========================================
    # Task 2: Generate equity_summary_by_module.csv
    # Group by Module
    # ==========================================
    print("Generating equity_summary_by_module.csv...")
    
    module_summary = df.groupby('Module')['Construction Points'].sum().reset_index()
    
    module_map = {
        'Accounting App': 'Accounting App',
        'Web Console': 'Web Console',
        'AI Advisor': 'AI Advisor',
        'Macro Data': 'Macro Data'
    }
    
    ordered_modules = ['Accounting App', 'Web Console', 'AI Advisor', 'Macro Data']
    
    output_rows_module_summary = []
    output_rows_module_summary.append(['產品模組', '施工價值 (點)', '佔總價值比例', '換算工時'])
    
    for mod in ordered_modules:
        # Handle case where module might not exist in data
        if mod in module_summary['Module'].values:
            points = module_summary.loc[module_summary['Module'] == mod, 'Construction Points'].sum()
        else:
            points = 0
            
        name = module_map.get(mod, mod)
        
        percentage = (points / total_construction_points * 100)
        man_months = points / 2000
        
        output_rows_module_summary.append([
            name,
            f"{points:,}",
            f"{percentage:.1f}%",
            f"{man_months:.1f} 人月"
        ])
        
    # Total Row
    output_rows_module_summary.append([
        "**總計**",
        f"**{total_construction_points:,}**",
        "**100.0%**",
        f"**{total_mm:.1f} 人月**"
    ])
    
    pd.DataFrame(output_rows_module_summary).to_csv(output_path_component_summary, index=False, header=False, encoding='utf-8-sig')


    # ==========================================
    # Task 3: Generate equity_consistency_analysis.csv
    # ==========================================
    print("Generating equity_consistency_analysis.csv...")
    
    # Calculate Ops points per module
    mod_ops_summary = df.groupby('Module')['Operation Points'].sum()
    mod_const_summary = df.groupby('Module')['Construction Points'].sum()
    
    # tiers definition moved to global TIERS
    
    output_rows_consistency = []
    output_rows_consistency.append(['Tier', '月費', '年費', '累積施工 (點)', '年化維運 (點)', '維運/定價比'])
    
    for tier in TIERS:
        const = 0
        ops_annual = 0
        
        for m in tier['modules']:
            const += mod_const_summary.get(m, 0)
            if not tier.get('is_tier_0', False):
                ops_annual += mod_ops_summary.get(m, 0) * 12
                
        # Ratio
        ratio_str = "-"
        if ops_annual > 0:
            price_val = parse_int(tier['price_yr'])
            if price_val > 0:
                ratio = ops_annual / price_val
                ratio_str = f"{int(round(ratio))}:1"
                
        output_rows_consistency.append([
            tier['name'],
            tier['price_mo'],
            tier['price_yr'],
            f"{const:,}",
            f"{ops_annual:,}",
            ratio_str
        ])
        
    pd.DataFrame(output_rows_consistency).to_csv(output_path_consistency, index=False, header=False, encoding='utf-8-sig')

    print("All files generated successfully.")

if __name__ == "__main__":
    main()
