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
    // Note: Don't destruct tx_list - it's owned by the block

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

    // Use normal mode to keep all blocks
    settings.database.db_mode = kth_db_mode_normal;
    settings.database.directory = "blockchain";

    printf("  Network: Bitcoin Cash Mainnet\n");
    printf("  Database mode: Normal\n");
    printf("  Database directory: %s\n\n", settings.database.directory);

    // Construct and initialize node
    printf("Constructing node...\n");
    // kth_node_t node = kth_node_construct(&settings, 1);  // stdout enabled
    kth_node_t node = kth_node_construct(&settings, 0);  // stdout disabled

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

    // Target block: First person-to-person Bitcoin transaction
    // (Satoshi Nakamoto to Hal Finney on January 12, 2009)
    kth_size_t target_height = 170;

    // Wait for blockchain to sync to target height
    printf("Waiting for blockchain to sync to block %llu...\n", (unsigned long long)target_height);
    printf("(Press Ctrl-C to stop)\n\n");

    uint64_t current_height = 0;
    while (keep_running && current_height < target_height) {
        res = kth_chain_sync_last_height(chain, &current_height);
        if (res == kth_ec_success) {
            printf("\r🔄 Syncing blockchain... Current height: %llu / %llu",
                   (unsigned long long)current_height, (unsigned long long)target_height);
            fflush(stdout);
        }
        sleep(2);
    }

    if (!keep_running) {
        printf("\n\nShutdown requested during sync.\n");
        kth_node_destruct(node);
        return 0;
    }

    printf("\n\n✓ Blockchain synced to height %llu\n\n", (unsigned long long)current_height);

    // Fetch the historic block
    printf("Fetching historic block at height %llu...\n", (unsigned long long)target_height);
    printf("(First person-to-person transaction: Satoshi to Hal Finney)\n\n");
    kth_chain_async_block_by_height(chain, NULL, target_height, block_handler);

    // Keep running until Ctrl-C
    printf("Node is running. Press Ctrl-C to stop.\n\n");

    while (keep_running) {
        sleep(10);
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
