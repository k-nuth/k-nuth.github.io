#include <signal.h>
#include <stdatomic.h>
#include <stdio.h>
#include <unistd.h>
#include <kth/capi.h>
 
#define PIZZA_BLOCK 57043 // Bitcoin Pizza Day (May 22, 2010)
 
atomic_int keep_running = 1;
atomic_int block_received = 0;
 
void handle_signal(int sig) {
  keep_running = 0;
  printf("\nInterrupted by signal\n");
}
 
void print_block(kth_chain_t c, void* ctx, kth_error_code_t err, kth_block_t block, kth_size_t h) {
  if (err != kth_ec_success) {
    printf("Error fetching block: %d\n", err);
    block_received = 1;
    return;
  }
  kth_hash_t hash = kth_chain_block_hash(block);
  printf("Block %llu: ", (unsigned long long)h);
  for (int i = 31; i >= 0; --i) printf("%02x", hash.hash[i]);
  printf("\n");
  kth_chain_block_destruct(block);
  block_received = 1;
}
 
int main() {
  signal(SIGINT, handle_signal);
  signal(SIGTERM, handle_signal);
 
  kth_settings cfg = kth_config_settings_default(kth_network_mainnet);
  kth_node_t node = kth_node_construct(&cfg, 0);
 
  printf("Starting node...\n");
  fflush(stdout);
  if (!node || kth_node_init_run_sync(node, kth_start_modules_all) != kth_ec_success) return 1;
  printf("✓ Node running\n");
 
  kth_chain_t chain = kth_node_get_chain(node);
  uint64_t h = 0;
  kth_chain_sync_last_height(chain, &h);
 
  // Wait for sync to PIZZA_BLOCK
  while (keep_running && h < PIZZA_BLOCK) {
    printf("\r🔄 Syncing... %llu/%llu", h, (uint64_t)PIZZA_BLOCK);
    fflush(stdout);
    sleep(1);
    kth_chain_sync_last_height(chain, &h);
  }
 
  if (!keep_running) {
    kth_node_destruct(node);
    return 0;
  }
 
  printf("\n✓ Synced to block %llu\n", h);
  printf("Fetching block %llu (Bitcoin Pizza Day)...\n", (uint64_t)PIZZA_BLOCK);
  kth_chain_async_block_by_height(chain, NULL, PIZZA_BLOCK, print_block);
 
  // Wait for block to be received or interrupted
  while (keep_running && !block_received) {
    sleep(1);
  }
 
  kth_node_destruct(node);
  return 0;
}
