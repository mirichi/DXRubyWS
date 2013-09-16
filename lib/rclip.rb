# http://cup.sakura.ne.jp/hiki/?prog01_guide

# rclip.rb version 1.0: (coding: utf-8)  2013/09/07
  # library on the clipboard operation
  # Cf. the web site below
  # http://tailcodenote.shisyou.com/code/ruby/006.html
  # Copyright (C) T. Yoshiizumi, 2013 All rights reserved.

# module for clipboard of MS-Windows
if RUBY_VERSION < "2.0"
  require "Win32API"
  if RUBY_VERSION.to_f >= 1.9
    require "dl"
  end

  module Rclip
    @@OpenClipboard = Win32API.new('user32', 'OpenClipboard', ['I'], 'I')
    @@CloseClipboard = Win32API.new('user32', 'CloseClipboard', [], 'I')
    @@GetClipboardData = Win32API.new('user32', 'GetClipboardData', ['I'], 'I')
    @@SetClipboardData = Win32API.new('user32',
        'SetClipboardData', ['I', 'I'], 'I')
    @@EmptyClipboard = Win32API.new('user32', 'EmptyClipboard', [], 'I')
    @@EnumClipboardFormats = Win32API.new('user32',
        'EnumClipboardFormats', ['I'], 'I')

    @@GlobalAlloc = Win32API.new('kernel32', 'GlobalAlloc', ['I','I'], 'I')
    @@GlobalLock = Win32API.new('kernel32', 'GlobalLock', ['I'], 'P');   #get
    @@GlobalLockI = Win32API.new('kernel32', 'GlobalLock', ['I'], 'I');  #set
    @@GlobalUnlock = Win32API.new('kernel32', 'GlobalUnlock', ['I'], 'I')
    @@GlobalSize = Win32API.new('kernel32', 'GlobalSize', ['I'], 'I')
    @@GlobalFree = Win32API.new('kernel32', 'GlobalFree', ['I'], 'I')
    if RUBY_VERSION.to_f >= 1.9
      begin
        @@memcpy = Win32API.new('msvcrt', 'memcpy', ['I', 'P', 'I'], 'I')
      rescue
        STDERR.puts "need 'msvcrt.dll' for copying data to Clipboard."
      end
    end

    @@lstrcpy = Win32API.new('kernel32', 'lstrcpyA', ['P', 'P'], 'P')
    @@lstrlen = Win32API.new('kernel32', 'lstrlenA', ['P'], 'I')

    CF = {:CF_TEXT=>1, :CF_BITMAP=>2, :CF_METAFILEPICT=>3, :CF_SYLK=>4,
      :CF_DIF=>5, :CF_TIFF=>6, :CF_OEMTEXT=>7, :CF_DIB=>8, :CF_PALETTE=>9,
      :CF_PENDATA=>10, :CF_RIFF=>11, :CF_WAVE=>12, :CF_UNICODETEXT=>13,
      :CF_ENHMETAFILE=>14, :CF_HDROP=>15, :CF_LOCALE=>16, :CF_DIBV5=>17,
      :CF_OWNERDISPLAY=>0x80, :CF_DSPTEXT=>0x81, :CF_DSPBITMAP=>0x82,
      :CF_DSPMETAFILEPICT=>0x83, :CF_DSPENHMETAFILE=>0x8e,
      :ObjectLink=>0xc002, :OwnerLink=>0xc003, :Native=>0xc004,
      :DataObject=>0xc009, :TravelBand=>0xc27e, :IBM_Tivoli_Win=>0xc282,
      :QueryBuilderBand=>0xc296, :TOOLBAR_CUSTOMIZE=>0xc299,
      :"Address Band Root"=>0xc27f, :"RichEdit Binary"=>0xc297,
      :"Object Descriptor"=>0xc00e, :"Preferred DropEffect"=>0xc157,
      :"WPD NSE PnPDevicePath"=>0xc281, :"Ole Private Data"=>0xc013,
      :"Embed Source"=>0xc00b, :"Link Source"=>0xc00d,
      :"Link Source Descriptor"=>0xc00f, :"Rich Text Format"=>0xc0ec}
    GM = {:GMEM_FIXED=>0, :GMEM_MOVEABLE=>2,
      :GMEM_ZEROINIT=>0x40, :GHND=>0x42}

    module_function()
    def clear()
      @@EmptyClipboard.Call()
    end

    def getData(cf = :CF_TEXT)
      cf = CF[cf]  if cf.class == Symbol
      clpdata = ""
      while @@OpenClipboard.Call(0) == 0
        sleep(0.2)
      end
      begin
        if (hnd = @@GetClipboardData.Call(cf)) != 0
          if ptr = @@GlobalLock.Call(hnd)
            clpdata = (RUBY_VERSION < "1.9") ? ptr : DL::CPtr[ptr].to_s
            @@GlobalUnlock.Call(hnd)
          end
        end
      ensure
        @@CloseClipboard.Call
      end
      return clpdata
    end

    def setData(str, cf = :CF_TEXT, gm = :GHND)
      cf = CF[cf]  if cf.class == Symbol
      gm = GM[gm]  if gm.class == Symbol
      while @@OpenClipboard.Call(0) == 0
        sleep(0.2)
      end
      if clear() != 0
        len = @@lstrlen.Call(str)
        hmem = @@GlobalAlloc.Call(gm, len+1)
        if RUBY_VERSION < "1.9"
          pmem = @@GlobalLockI.Call(hmem)
          @@lstrcpy.Call(pmem, str)
        else
          pmem = @@GlobalLock.Call(hmem)
          @@memcpy.Call(pmem, str, len+1)
        end
        @@SetClipboardData.Call(cf, hmem)
        @@GlobalUnlock.Call(hmem)
        @@CloseClipboard.Call
      end
    end

    def formats()
      res = []
      while @@OpenClipboard.Call(0) == 0
        sleep(0.2)
      end
      fmt = @@EnumClipboardFormats.Call(0)
      while fmt != 0
        fs = (RUBY_VERSION < "1.9") ? CF.index(fmt) : CF.key(fmt)
        fs = fmt  unless fs
        res << fs
        fmt = @@EnumClipboardFormats.Call(fmt)
      end
      return res
    end
  end
## end of Rclip module for ruby ver 1.8 | 1.9

else  # if RUBY_VERSION >= "2.0"
  require "fiddle"
  require "fiddle/import"

  module Rclip
    module W
      extend Fiddle::Importer
      dlload 'user32.dll', 'kernel32.dll', 'msvcrt.dll'
      extern "int OpenClipboard(int)"
      extern "int CloseClipboard()"
      extern "int GetClipboardData(int)"
      extern "int SetClipboardData(int, int)"
      extern "int EmptyClipboard()"
      extern "int EnumClipboardFormats(int)"
      extern "int GlobalAlloc(int, int)"
      extern "char* GlobalLock(int)"
      extern "int GlobalLock(int)"
      extern "int GlobalUnlock(int)"
      extern "int GlobalSize(int)"
      extern "int GlobalFree(int)"
      extern "int memcpy(int, char*, int)"
      extern "char* lstrcpyA(char*, char*)"
      extern "int lstrlenA(char*)"
    end

    CF = {:CF_TEXT=>1, :CF_BITMAP=>2, :CF_METAFILEPICT=>3, :CF_SYLK=>4,
      :CF_DIF=>5, :CF_TIFF=>6, :CF_OEMTEXT=>7, :CF_DIB=>8, :CF_PALETTE=>9,
      :CF_PENDATA=>10, :CF_RIFF=>11, :CF_WAVE=>12, :CF_UNICODETEXT=>13,
      :CF_ENHMETAFILE=>14, :CF_HDROP=>15, :CF_LOCALE=>16, :CF_DIBV5=>17,
      :CF_OWNERDISPLAY=>0x80, :CF_DSPTEXT=>0x81, :CF_DSPBITMAP=>0x82,
      :CF_DSPMETAFILEPICT=>0x83, :CF_DSPENHMETAFILE=>0x8e,
      :ObjectLink=>0xc002, :OwnerLink=>0xc003, :Native=>0xc004,
      :DataObject=>0xc009, :TravelBand=>0xc27e, :IBM_Tivoli_Win=>0xc282,
      :QueryBuilderBand=>0xc296, :TOOLBAR_CUSTOMIZE=>0xc299,
      :"Address Band Root"=>0xc27f, :"RichEdit Binary"=>0xc297,
      :"Object Descriptor"=>0xc00e, :"Preferred DropEffect"=>0xc157,
      :"WPD NSE PnPDevicePath"=>0xc281, :"Ole Private Data"=>0xc013,
      :"Embed Source"=>0xc00b, :"Link Source"=>0xc00d,
      :"Link Source Descriptor"=>0xc00f, :"Rich Text Format"=>0xc0ec}
    GM = {:GMEM_FIXED=>0, :GMEM_MOVEABLE=>2,
      :GMEM_ZEROINIT=>0x40, :GHND=>0x42}

    module_function()
    def clear()
      W.EmptyClipboard()
    end

    def getData(cf = :CF_TEXT)
      cf = CF[cf]  if cf.class == Symbol
      clpdata = ""
      while W.OpenClipboard(0) == 0
        sleep(0.2)
      end
      begin
        if (hnd = W.GetClipboardData(cf)) != 0
          if (ptr = W.GlobalLock(hnd))
            clpdata = Fiddle::Pointer[ptr].to_s
            W.GlobalUnlock(hnd)
          end
        end
      ensure
        W.CloseClipboard()
      end
      return clpdata
    end

    def setData(str, cf = :CF_TEXT, gm = :GHND)
      cf = CF[cf]  if cf.class == Symbol
      gm = GM[gm]  if gm.class == Symbol
      while W.OpenClipboard(0) == 0
        sleep(0.2)
      end
      if clear() != 0
        len = W.lstrlenA(str)
        hmem = W.GlobalAlloc(gm, len+1)
        pmem = W.GlobalLock(hmem)
        W.memcpy(pmem, Fiddle::Pointer[str], len+1)
        W.SetClipboardData(cf, hmem)
        W.GlobalUnlock(hmem)
        W.CloseClipboard()
      end
    end

    def formats()
      res = []
      while W.OpenClipboard(0) == 0
        sleep(0.2)
      end
      fmt = W.EnumClipboardFormats(0)
      while fmt != 0
        fs = (RUBY_VERSION < "1.9") ? CF.index(fmt) : CF.key(fmt)
        fs = fmt  unless fs
        res << fs
        fmt = W.EnumClipboardFormats(fmt)
      end
      return res
    end
  end
## end of Rclip module for ruby ver 2.0
end
