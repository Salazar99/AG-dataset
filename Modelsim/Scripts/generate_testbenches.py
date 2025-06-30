# scripts/generate_testbenches.py
import os
import re
import sys

# --- Configuration ---
DESIGN_PATH = '../rtl/Arithmetic/Accumulator/accu/verified_accu.v'  # Folder containing RTL designs relative to RTL_DIR
TEMPLATES_DIR = '../tb_templates'
GENERATED_TBS_DIR = '../generated_tbs'

# Ensure output directory exists
os.makedirs(GENERATED_TBS_DIR, exist_ok=True)

# --- Verilog Parsing Function (Using Regex - Basic, consider sv-parser for robust parsing) ---
def parse_verilog_module_regex(filepath):
    module_info = {'name': None, 'inputs': [], 'outputs': [], 'inouts': []}
    with open(filepath, 'r') as f:
        content = f.read()

    # Find module name
    module_match = re.search(r'module\s+(\w+)\s*\(', content, re.DOTALL)
    if not module_match:
        print(f"Warning: Could not find module definition in {filepath}")
        return None
    module_info['name'] = module_match.group(1)

    # Extract port list content
    port_list_match = re.search(r'module\s+\w+\s*\((.*?)\);', content, re.DOTALL)
    if not port_list_match:
        print(f"Warning: Could not find port list for module {module_info['name']} in {filepath}")
        return module_info

    port_list_str = port_list_match.group(1)

    # Split by comma and process each port declaration
    ports_raw = [p.strip() for p in port_list_str.split(',')]

    for port_decl in ports_raw:
        if not port_decl:
            continue

        # Regex to capture direction, optional type/signed, optional width, and name
        match = re.search(r'(input|output|inout)\s*(reg|wire|logic)?\s*(signed)?\s*(\[\s*\d+\s*:\s*\d+\s*\])?\s*(\w+)', port_decl)
        if match:
            direction = match.group(1)
            width = match.group(4) if match.group(4) else ''
            name = match.group(5)
            width = re.sub(r'\s+', '', width) if width else ''

            port_data = {'name': name, 'width': width}
            if direction == 'input':
                module_info['inputs'].append(port_data)
            elif direction == 'output':
                module_info['outputs'].append(port_data)
            elif direction == 'inout':
                module_info['inouts'].append(port_data)
        else:
            print(f"Warning: Could not parse port declaration: '{port_decl}' in {filepath}. Skipping.")

    return module_info

# --- SystemVerilog Testbench Generation ---
#Due to systemverilog madness regarding randomization, we need to generate 8 files for a sigle testbench.
def generate_testbench(module_info, template_content):
    module_name = module_info['name']
    if not module_name:
        sys.exit(f"ERROR: Module name not found in the provided module information.")

    print(f"INFO: Generating testbench for module '{module_name}'")




    #--DRIVER--
    driver_template = template_content['driver']
    driver_content = driver_template.replace('@MODULE_NAME@', module_name)
    # string example: MODULE_NAME_vif.in=trans.in
    intf_to_trans_str = ""
    for p in module_info['inputs']:
        if p['name'] == 'clk' or 'rst' in p['name']:
            continue
        intf_to_trans_str += f"{module_name}_vif.{p['name']}=trans.{p['name']};\n"
    driver_content = driver_content.replace('@INTF_TO_TRANS@', intf_to_trans_str)
    #done

    #--ENVIRONMENT--
    environment_template = template_content['environment']
    environment_content = environment_template.replace('@MODULE_NAME@', module_name)
    #done

    #--GENERATOR--
    generator_template = template_content['generator']
    #done

    #--INTERFACE--
    interface_template = template_content['Interface']
    interface_content = interface_template.replace('@MODULE_NAME@', module_name)
    logic_signals_decl_str = ""
    input_signals_decl_str = ""
    output_signals_decl_str = ""
    for p in module_info['inputs']:
        if p['name'] == 'clk' or 'rst' in p['name']:
            continue
        input_signals_decl_str += f"{p['name']},"
        logic_signals_decl_str += f"  logic {p['width']} {p['name']};\n"
        
    input_signals_decl_str += f"clk, rst,\n"
    input_signals_decl_str = input_signals_decl_str.rstrip(',\n')

    for p in module_info['outputs']:
        output_signals_decl_str += f"{p['name']},"
        if p['name'] == 'clk' or 'rst' in p['name']:
            continue
        logic_signals_decl_str += f"  logic {p['width']} {p['name']};\n"
    output_signals_decl_str = output_signals_decl_str.rstrip(',')
    
    interface_content = interface_content.replace('@LOGIC_SIGNALS_DECLARATION@', logic_signals_decl_str)
    interface_content = interface_content.replace('@INPUT_SIGNAL_DECLARATIONS@', input_signals_decl_str)
    interface_content = interface_content.replace('@OUTPUT_SIGNAL_DECLARATIONS@', output_signals_decl_str)
    #done
    
    #--TEST--
    test_template = template_content['test']
    test_content = test_template.replace('@MODULE_NAME@', module_name)
    
    # string example: in.rand_mode(1);
    randomize_signals_str = ""
    for p in module_info['inputs']:
        if p['name'] == 'clk' or 'rst' in p['name']:
            continue
        randomize_signals_str += f"  {p['name']}.rand_mode(1);\n"
    test_content = test_content.replace('@RANDOMIZE_SIGNALS@', randomize_signals_str)
    #done

    #--TRANSACTION--
    transaction_template = template_content['transaction']
    transaction_content = transaction_template.replace('@MODULE_NAME@', module_name)
    
    # string example: rand logic [3:0] in;
    rand_logic_signals_decl_str =""
    for p in module_info['inputs']:
        if p['name'] == 'clk' or 'rst' in p['name']:
            continue
        rand_logic_signals_decl_str += f"  rand logic {p['width']} {p['name']};\n"
    transaction_content = transaction_content.replace('@RAND_SIGNAL_DECLARATION@', rand_logic_signals_decl_str)

    # string example trans.in = this.in;
    trans_signals_assignments_str = ""
    for p in module_info['inputs']:
        if p['name'] == 'clk' or 'rst' in p['name']:
            continue
        trans_signals_assignments_str += f"  trans.{p['name']} = this.{p['name']};\n"
    transaction_content = transaction_content.replace('@TRANSACTION_SIGNALS_ASS@', trans_signals_assignments_str)
    #done

    #--TESTBENCH--
    testbench_template = template_content['testbench']
    testbench_content = testbench_template.replace('@MODULE_NAME@', module_name)
    #done

    #--Write each tb file in GENERATED_TBS_DIR--
    output_filepath = os.path.join(GENERATED_TBS_DIR, f"{module_name}")
    tb_output_filepath = os.path.join(output_filepath, "tb")
    os.makedirs(output_filepath, exist_ok=True)
    print(f"INFO: Writing testbench files to '{output_filepath}'")
    try:
        driver_filepath = os.path.join(tb_output_filepath, f"driver.sv")
        with open(driver_filepath, 'w') as f:
            f.write(driver_content)
    except Exception as e:
        print(f"ERROR: Failed to write driver file '{driver_filepath}'. Exception: {e}")
        return

    try:
        environment_filepath = os.path.join(tb_output_filepath, f"environment.sv")
        with open(environment_filepath, 'w') as f:
            f.write(environment_content)
    except Exception as e:
        print(f"ERROR: Failed to write environment file '{environment_filepath}'. Exception: {e}")
        return

    try:
        generator_filepath = os.path.join(tb_output_filepath, f"generator.sv")
        with open(generator_filepath, 'w') as f:
            f.write(generator_template)
    except Exception as e:
        print(f"ERROR: Failed to write generator file '{generator_filepath}'. Exception: {e}")
        return

    try:
        interface_filepath = os.path.join(tb_output_filepath, f"{module_name}Interface.sv")
        with open(interface_filepath, 'w') as f:
            f.write(interface_content)
    except Exception as e:
        print(f"ERROR: Failed to write interface file '{interface_filepath}'. Exception: {e}")
        return

    try:
        test_filepath = os.path.join(tb_output_filepath, f"test.sv")
        with open(test_filepath, 'w') as f:
            f.write(test_content)
    except Exception as e:
        print(f"ERROR: Failed to write test file '{test_filepath}'. Exception: {e}")
        return

    try:
        transaction_filepath = os.path.join(tb_output_filepath, f"transaction.sv")
        with open(transaction_filepath, 'w') as f:
            f.write(transaction_content)
    except Exception as e:
        print(f"ERROR: Failed to write transaction file '{transaction_filepath}'. Exception: {e}")
        return

    try:
        testbench_filepath = os.path.join(tb_output_filepath, f"testbench.sv")
        with open(testbench_filepath, 'w') as f:
            f.write(testbench_content)
    except Exception as e:
        print(f"ERROR: Failed to write testbench file '{testbench_filepath}'. Exception: {e}")
        return

    print(f"INFO: Testbench generated for module '{module_name}' at '{tb_output_filepath}'")

    # Modify rtl implementation to work with the generated testbench
    try:
        with open(DESIGN_PATH, 'r') as f:
            rtl_content = f.read()
    except FileNotFoundError:
        print(f"ERROR: RTL file '{DESIGN_PATH}' not found. Please check the path.")
        return
    
    
    
    
    
    # Replace input/output port declaration with {module_name}_intf intf in RTL file
    rtl_content = re.sub(
        r'(module\s+\w+\s*\([^)]*\);)',
        rf'module {module_name} ({module_name}_intf intf);',
        rtl_content,
        flags=re.DOTALL
    )
  
    # Replace all input/output port references with intf.{port_name}
    for p in module_info['inputs'] + module_info['outputs']:
        repl = f'intf.{p["name"]}'
        if "rst" in p["name"]:
            repl = f'intf.rst'
        rtl_content = re.sub(
            rf'\b{p["name"]}\b',
            repl,
            rtl_content
        )
    
    #Remove any timescale directive from the RTL file
    rtl_content = re.sub(r'`timescale\s+\d+\w+/\d+\w+', '', rtl_content)
    
    # Write the modified RTL content back to the file
    
    rtl_output_filepath = os.path.join(output_filepath, "rtl")
    
    try:
        with open(rtl_output_filepath + f"/{module_name}.sv", 'w') as f:
            f.write(rtl_content)
        print(f"INFO: Updated RTL file '{rtl_output_filepath + f'{module_name}.sv'}' with interface declaration.")
    except Exception as e:
        print(f"ERROR: Failed to write updated RTL file '{rtl_output_filepath + f'{module_name}.sv'}'. Exception: {e}")

# --- Read Testbench Templates ---
# Reads the testbench templates from the specified directory and returns them as a dictionary.
def read_templates():
    templates = {}
    try:
        with open(TEMPLATES_DIR + "/driver.sv", 'r') as f:
            templates['driver'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/driver.sv'}'")
        exit(1)

    try:
        with open(TEMPLATES_DIR + "/environment.sv", 'r') as f:
            templates['environment'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/environment.sv'}'")
        exit(1)

    try:
        with open(TEMPLATES_DIR + "/generator.sv", 'r') as f:
            templates['generator'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/generator.sv'}'")
        exit(1)

    try:
        with open(TEMPLATES_DIR + "/Interface.sv", 'r') as f:
            templates['Interface'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/Interface.sv'}'")
        exit(1)
        
    try:
        with open(TEMPLATES_DIR + "/test.sv", 'r') as f:
            templates['test'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/test.sv'}'")
        exit(1)

    try:
        with open(TEMPLATES_DIR + "/testbench.sv", 'r') as f:
            templates['testbench'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/testbench.sv'}'")
        exit(1)

    try:
        with open(TEMPLATES_DIR + "/transaction.sv", 'r') as f:
            templates['transaction'] = f.read()
    except FileNotFoundError:
        print(f"ERROR: Testbench template file not found: '{TEMPLATES_DIR + '/transaction.sv'}'")
        exit(1)

    return templates

# --- Main execution ---
if __name__ == '__main__':
    print(f"INFO: Generating testbenches for RTL designs in '{DESIGN_PATH}'")

    tb_templates = read_templates()

    if not os.path.exists(DESIGN_PATH):
        print(f"ERROR: RTL module '{DESIGN_PATH}' does not exist. Please check the path.")
        exit(1)

    # Get inputs/outputs/module name from RTL file
    module_info = parse_verilog_module_regex(DESIGN_PATH)

    if module_info and module_info['name']:
        generate_testbench(module_info, tb_templates)
    else:
        print(f"ERROR: Could not extract module information from {DESIGN_PATH}.")
        sys.exit(1)

    print("\nINFO: Testbench generation complete.")
