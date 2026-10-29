import pathlib
import re
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


class TerraformSafetyTests(unittest.TestCase):
    def test_cloud_creation_is_opt_in(self):
        variables = (ROOT / "terraform/variables.tf").read_text()
        self.assertRegex(variables, r'variable "enable_deployment"\s*\{[^}]*default\s*=\s*false')
        self.assertIn("AZURE_COST_REVIEWED_AND_APPROVED", variables)

    def test_each_resource_is_behind_deployment_gate(self):
        main = (ROOT / "terraform/main.tf").read_text()
        resource_blocks = re.findall(r'resource\s+"[^"]+"\s+"[^"]+"\s*\{([^}]+)', main)
        self.assertGreaterEqual(len(resource_blocks), 8)
        for block in resource_blocks:
            self.assertRegex(block, r'count\s*=\s*var\.enable_deployment')

    def test_no_public_ip_or_open_ssh_rule_is_defined(self):
        terraform = "\n".join(path.read_text() for path in (ROOT / "terraform").glob("*.tf"))
        self.assertNotIn('azurerm_public_ip', terraform)
        self.assertNotRegex(terraform, r'destination_port_range\s*=\s*"22"')
        self.assertNotRegex(terraform, r'source_address_prefix\s*=\s*"0\.0\.0\.0/0"')

    def test_optional_billable_services_default_off(self):
        variables = (ROOT / "terraform/variables.tf").read_text()
        self.assertRegex(variables, r'variable "enable_linux_vm"\s*\{[^}]*default\s*=\s*false')
        self.assertRegex(variables, r'variable "enable_log_analytics"\s*\{[^}]*default\s*=\s*false')


if __name__ == "__main__":
    unittest.main()
