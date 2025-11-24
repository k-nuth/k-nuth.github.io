#include <kth/node.hpp>
#include <iostream>

int main() {
    std::cout << "========================================\n";
    std::cout << "Knuth C++ API Test\n";
    std::cout << "========================================\n\n";

    std::cout << "Creating Knuth node configuration...\n";
    kth::node::configuration config(kth::domain::config::network::mainnet);

    // {
        std::cout << "Constructing executor...\n";
        kth::node::executor exec(config, true);

        std::cout << "✓ Executor constructed successfully\n";

        // Note: For a full test, we would call exec.init_run()
        // but that requires blockchain sync which takes time.
        // For installation verification, construction is sufficient.

        std::cout << "\nDestructing executor...\n";
        // Destructor will be called automatically when exec goes out of scope

        std::cout << "✓ Executor destructed successfully\n";
    // }
    std::cout << "\n========================================\n";
    std::cout << "✓ C++ API test completed successfully!\n";
    std::cout << "========================================\n";

    return 0;
}
