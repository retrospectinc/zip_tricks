# A simple stateful class for keeping track of a CRC32 value through multiple writes
class ZipTricks::StreamCRC32
  # Compute a CRC32 value from an IO object. The object should respond to `read` and `eof?`
  #
  # @param io[IO] the IO to read the data from
  # @return [Fixnum] the computed CRC32 value
  def self.from_io(io)
    crc = new
    crc << io.read(1024 * 512) until io.eof?
    crc.to_i
  end
  
  # Creates a new streaming CRC32 calculator
  def initialize
    @crc = Zlib.crc32('')
  end
  
  # Append data to the CRC32. Updates the contained CRC32 value in place.
  #
  # @param blob[String] the string to compute the CRC32 from
  # @return [self]
  def <<(blob)
    @crc = Zlib.crc32_combine(@crc, Zlib.crc32(blob), blob.bytesize)
    self
  end
  
  # Returns the CRC32 value computed so far
  #
  # @return crc[Fixnum] the updated CRC32 value for all the blobs so far
  def to_i
    @crc
  end
  
  # Appends a known CRC32 value to the current one, and combines the
  # contained CRC32 value in-place.
  #
  # @param crc32[Fixnum] the CRC32 value to append
  # @param blob_size[Fixnum] the size of the daata the `crc32` is computed from
  # @return crc[Fixnum] the updated CRC32 value for all the blobs so far
  def append(crc32, blob_size)
    @crc = Zlib.crc32_combine(@crc, crc32, blob_size)
  end
end