#include <atomic>
#include <csignal>
#include <print>
#include <thread>
#include <kth/node.hpp>
 
using namespace kth;
 
constexpr uint64_t pizza_block = 57043; // Bitcoin Pizza Day (May 22, 2010)
 
std::atomic<bool> keep_running{true};
std::atomic<bool> block_received{false};
 
void handle_signal(int sig) {
  keep_running = false;
  std::println("\nInterrupted by signal");
}
 
int main() {
  std::signal(SIGINT, handle_signal);
  std::signal(SIGTERM, handle_signal);
 
  node::configuration config{domain::config::network::mainnet};
  node::full_node node{config};
 
  std::print("Starting node...\n");
 
  bool started = false;
  node.start([&](code const& ec) {
    if (ec) {
      std::println("Error starting node: {}", ec.message());
      return;
    }
    started = true;
    std::println("✓ Node running");
  });
 
  while (!started && keep_running) {
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
 
  if (!started) return 1;
 
  auto& chain = node.chain();
 
  // Wait for sync to pizza_block
  while (keep_running) {
    size_t h;
    if (!chain.get_last_height(h)) break;
 
    if (h >= pizza_block) break;
 
    std::print("\r🔄 Syncing... {}/{}", h, pizza_block);
    std::this_thread::sleep_for(std::chrono::seconds(1));
  }
 
  if (!keep_running) {
    node.stop();
    return 0;
  }
 
  std::println("\n✓ Synced to block {}", pizza_block);
  std::println("Fetching block {} (Bitcoin Pizza Day)...", pizza_block);
 
  chain.fetch_block(pizza_block, [](code const& ec, blockchain::block_const_ptr block, size_t h) {
    if (ec) {
      std::println("Error fetching block: {}", ec.message());
      block_received = true;
      return;
    }
 
    auto hash = block->hash();
    std::print("Block {}: ", h);
    for (int i = hash.size() - 1; i >= 0; --i) {
      std::print("{:02x}", (int)hash[i]);
    }
    std::println("");
    block_received = true;
  });
 
  // Wait for block to be received or interrupted
  while (keep_running && !block_received) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
  }
 
  node.stop();
  return 0;
}
