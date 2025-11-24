// Copyright (c) 2016-2025 Knuth Project developers.
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <kth/capi.h>

// Global flag to handle Ctrl-C
static volatile int keep_running = 1;

void handle_signal(int sig) {
    printf("\n\nReceived signal %d, shutting down...\n", sig);
    keep_running = 0;
}

void block_handler(kth_chain_t chain, void* ctx, kth_error_code_t error, kth_block_t block, kth_size_t height) {
    if (error != kth_ec_success) {
        printf("Error fetching block at height %llu: %d\n", (unsigned long long)height, error);
        return;
    }

    printf("\n========================================\n");
    printf("Successfully fetched block at height: %llu\n", (unsigned long long)height);

    // Get block hash
    kth_hash_t hash = kth_chain_block_hash(block);
    printf("Block hash: ");
    for (int i = 31; i >= 0; --i) {
        printf("%02x", hash.hash[i]);
    }
    printf("\n");

    // Get number of transactions
    kth_transaction_list_t tx_list = kth_chain_block_transactions(block);
    kth_size_t tx_count = kth_chain_transaction_list_count(tx_list);
    printf("Number of transactions: %llu\n", (unsigned long long)tx_count);
    kth_chain_transaction_list_destruct(tx_list);

    printf("========================================\n\n");

    kth_chain_block_destruct(block);
}

int main(int argc, char* argv[]) {
    printf("========================================\n");
    printf("Knuth C API Example\n");
    printf("Fetching Bitcoin Cash blocks\n");
    printf("========================================\n\n");

    // Setup signal handlers for graceful shutdown
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    // Configure node settings
    printf("Configuring node...\n");
    kth_settings settings = kth_config_settings_default(kth_network_mainnet);

    // Use pruned mode for faster sync and less disk space
    settings.database.db_mode = kth_db_mode_pruned;
    settings.database.directory = "blockchain";

    printf("  Network: Bitcoin Cash Mainnet\n");
    printf("  Database mode: Pruned\n");
    printf("  Database directory: %s\n\n", settings.database.directory);

    // Construct and initialize node
    printf("Constructing node...\n");
    kth_node_t node = kth_node_construct(&settings, 1);  // stdout enabled

    if (node == NULL) {
        printf("ERROR: Failed to construct node\n");
        return 1;
    }
    printf("✓ Node constructed\n\n");

    printf("Initializing and starting node...\n");
    printf("(This may take a while on first run)\n");
    kth_error_code_t res = kth_node_init_run_sync(node, kth_start_modules_all);

    if (res != kth_ec_success) {
        printf("ERROR: Failed to initialize node: %d\n", res);
        kth_node_destruct(node);
        return 1;
    }
    printf("✓ Node initialized and running\n\n");

    // Get chain interface
    kth_chain_t chain = kth_node_get_chain(node);

    // Get current blockchain height
    uint64_t current_height;
    res = kth_chain_sync_last_height(chain, &current_height);

    if (res != kth_ec_success) {
        printf("ERROR: Could not get current height: %d\n", res);
        kth_node_destruct(node);
        return 1;
    }

    printf("Current blockchain height: %llu\n\n", (unsigned long long)current_height);

    // Fetch a historic block from the Satoshi era
    // Block 170 contains the first person-to-person Bitcoin transaction
    // (Satoshi Nakamoto to Hal Finney on January 12, 2009)
    kth_size_t target_height = 170;
    printf("Fetching historic block at height %llu...\n", (unsigned long long)target_height);
    printf("(First person-to-person transaction: Satoshi to Hal Finney)\n");
    kth_chain_async_block_by_height(chain, NULL, target_height, block_handler);

    // Keep running until Ctrl-C
    printf("\nNode is running. Press Ctrl-C to stop.\n");
    printf("Waiting for signal...\n\n");

    while (keep_running) {
        printf("[DEBUG] Before sleep, keep_running=%d\n", keep_running);
        fflush(stdout);
        sleep(10);
        printf("[DEBUG] After sleep, keep_running=%d\n", keep_running);

        // Check current height
        uint64_t current;
        if (kth_chain_sync_last_height(chain, &current) == kth_ec_success) {
            printf("[DEBUG] Current blockchain height: %llu\n", (unsigned long long)current);
        }
        fflush(stdout);
    }

    // Cleanup
    printf("\nCleaning up...\n");
    kth_node_destruct(node);
    printf("✓ Node destroyed\n");

    printf("\n========================================\n");
    printf("Knuth node stopped successfully\n");
    printf("========================================\n");

    return 0;
}
