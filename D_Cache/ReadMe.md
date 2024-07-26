## Data Cache Module

### Description
This Verilog module represents a cache controller for a CPU. The cache controller is designed to manage reading and writing data between the CPU and memory, handling cache hits and misses, and updating the cache as necessary.

### Signals

- `clock`: Clock signal.
- `reset`: Reset signal.
- `read`: Memory read signal from the CPU.
- `write`: Memory write signal from the CPU.
- `address`: 8-bit memory address from the ALU.
- `writedata`: 8-bit data from the register file.
- `mem_BUSY`: Indicates whether the data memory is busy.
- `mem_readdata`: Newly fetched 32-bit data word from memory.
- `readdata`: Data blocks read asynchronously from the cache and sent to the register file.
- `mem_read`: Indicates if data memory is being read.
- `mem_write`: Indicates if data memory is being written.
- `BUSY`: Signal to stall the CPU on a memory read/write instruction.
- `mem_address`: Block address to fetch data words from data memory.
- `mem_writedata`: Data word to write to data memory.

### Internal Registers and Wires

- `cache_VALID`: 8 registers to store 1-bit valid for each data block.
- `cache_DIRTY`: 8 registers to store 1-bit dirty for each data block.
- `cache_TAG`: 8 registers to store 3-bit tag for each data block.
- `cache_DATA`: 8 registers to store 32-bit data block.
- `VALID`: Valid bit corresponding to the index given by memory address.
- `DIRTY`: Dirty bit corresponding to the index given by memory address.
- `TAG`: Tag bits corresponding to the index given by memory address.
- `DATA`: 32-bit data corresponding to the index given by memory address.
- `compare`: Indicates whether the tag bits match.
- `HIT`: Indicates whether there is a cache hit or miss.
- `read_write_comb`: Indicates if either read or write signal is asserted.

### Functionality

1. **Reset Cache:**
   - On reset, all valid bits, dirty bits, tags, and data blocks in the cache are invalidated.

2. **Memory Read/Write Decision:**
   - Decides whether the CPU should be stalled in order to perform memory read or write.

3. **Data Fetch:**
   - Fetches 32-bit data corresponding to the index given by the memory address.

4. **Tag and Valid Bit Comparison:**
   - Compares the tag bits and checks the valid bit to determine if there is a cache hit.

5. **Cache Hit Handling:**
   - If there is a cache hit, reads or writes data to the cache based on the offset and updates the cache.

6. **Cache Miss Handling:**
   - If there is a cache miss and the block isn’t dirty, fetches the required data word from memory.
   - If there is a cache miss and the block is dirty, writes the block back to memory before fetching the required data word.

7. **Asynchronous Data Read:**
   - Reads data blocks asynchronously from the cache to send to the register file according to the offset.

### Cache Controller FSM

- **States:**
  - `IDLE`: Idle state.
  - `MEM_READ`: State for fetching the required data word from memory.
  - `MEM_WRITE`: State for writing data to the memory.
  - `CACHE_UPDATE`: State for updating the cache with the newly fetched data word.

- **Next State Logic:**
  - Transitions between states based on whether there is a cache hit or miss and whether the memory is busy.

- **Output Logic:**
  - Controls the signals for reading from the memory and updating the cache.

- **State Transition Logic:**
  - Transitions between states on the rising edge of the clock or reset signal.
