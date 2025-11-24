#include <kth/capi.h>
#include <stdio.h>
#include <inttypes.h>

int main() {
    printf("========================================\n");
    printf("Knuth C API Test\n");
    printf("========================================\n\n");

    printf("Creating Knuth node configuration...\n");
    kth_settings config = kth_config_settings_default(kth_network_mainnet);

    printf("Constructing node...\n");
    kth_node_t node = kth_node_construct(&config, 0);  // stdout disabled

    if (node == NULL) {
        printf("ERROR: Failed to construct node\n");
        return 1;
    }

    printf("✓ Node constructed successfully\n");

    // Note: For a full test, we would call kth_node_init_and_run_wait
    // but that requires blockchain sync which takes time.
    // For installation verification, construction is sufficient.

    printf("\nDestructing node...\n");
    kth_node_destruct(node);

    printf("✓ Node destructed successfully\n");
    printf("\n========================================\n");
    printf("✓ C API test completed successfully!\n");
    printf("========================================\n");

    fflush(stdout);
    fflush(stderr);

    return 0;
}
