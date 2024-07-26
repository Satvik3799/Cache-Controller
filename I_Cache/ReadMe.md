## Instruction Cache Module

### Description
This Verilog module represents an instruction cache for a CPU. The cache is designed to hold a small number of instructions to reduce the latency of instruction fetches. The module handles fetching instructions from memory, checking the cache for hits or misses, and updating the cache as necessary.

### Signals

- `current_instruction`: Specifies the instruction to be fetched.
- `clock`: Clock signal.
- `reset`: Reset signal.
- `inst_readdata`: Newly fetched 16-byte block from the instruction memory.
- `inst_BUSY`: Indicates whether the instruction memory is busy.
- `inst_read`: Signal to indicate if the instruction memory is being read.
- `output_instr`: Data blocks read asynchronously from the cache and sent to the CPU.
- `inst_address`: Block address to fetch the 16-byte block from the instruction memory.
- `BUSY`: Signal to stall the CPU when reading instruction memory.

### Internal Registers and Wires

- `cache_VALID`: Stores the valid bit for each data block.
- `cache_TAG`: Stores the tag bits for each data block.
- `cache_DATA`: Stores the 128-bit data blocks.
- `address`: Derived from `current_instruction` to fetch the required instruction from the cache.
- `VALID`: Valid bit corresponding to the index given by `address`.
- `TAG`: Tag bits corresponding to the index given by `address`.
- `DATA`: Data corresponding to the index given by `address`.
- `compare`: Indicates whether the tag bits match.
- `HIT`: Indicates whether there is a cache hit or miss.

### Functionality

1. **Reset Instruction Cache:**
   - On reset, all valid bits, tags, and data blocks in the cache are invalidated.

2. **Fetch Instruction:**
   - The 10-bit address is derived from `current_instruction` to fetch the required instruction from the cache.

3. **Stall CPU:**
   - The CPU is stalled if `current_instruction` is non-zero.

4. **Read Data from Cache:**
   - Data is read from the cache asynchronously based on the address.

5. **Tag and Valid Bit Comparison:**
   - Tags and valid bits are compared to determine if there is a cache hit.

6. **Cache Hit:**
   - If there is a cache hit, the CPU is not stalled.

7. **Read Instruction from Cache:**
   - Instruction is read from the cache and sent to the CPU based on the offset.

### Cache Controller FSM

- **States:**
  - `IDLE`: Idle state.
  - `MEM_READ`: State for fetching the required 16-byte block from memory.
  - `CACHE_UPDATE`: State for updating the cache with the newly fetched 16-byte block.

- **Next State Logic:**
  - Transitions between states based on whether there is a cache hit or miss and whether the memory is busy.

- **Output Logic:**
  - Controls the signals for reading from the instruction memory and updating the cache.

- **State Transition Logic:**
  - Transitions between states on the rising edge of the clock or reset signal.
