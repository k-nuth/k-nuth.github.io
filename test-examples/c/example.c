#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <kth/capi.h>

volatile int keep_running = 1;
void handle_signal(int sig) { keep_running = 0; }

void print_block(kth_chain_t c, void* ctx, kth_error_code_t err, kth_block_t block, kth_size_t h) {
  if (err != kth_ec_success) return;
  kth_hash_t hash = kth_chain_block_hash(block);
  printf("Block %llu: ", (unsigned long long)h);
  for (int i = 31; i >= 0; --i) printf("%02x", hash.hash[i]);
  printf("\n");
  kth_chain_block_destruct(block);
}

int main() {
  signal(SIGINT, handle_signal);

  kth_settings cfg = kth_config_settings_default(kth_network_mainnet);
  kth_node_t node = kth_node_construct(&cfg, 1);
  if (!node || kth_node_init_run_sync(node, kth_start_modules_all) != kth_ec_success) return 1;

  kth_chain_t chain = kth_node_get_chain(node);
  uint64_t h = 0;

  // Wait for sync to block 170
  while (keep_running && h < 170) {
    kth_chain_sync_last_height(chain, &h);
    printf("\r🔄 Syncing... %llu/170", h);
    fflush(stdout);
    sleep(1);
  }

  printf("\n");
  kth_chain_async_block_by_height(chain, NULL, 170, print_block);
  while (keep_running) sleep(1);

  kth_node_destruct(node);
  return 0;
}
