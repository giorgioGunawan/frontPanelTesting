using System;
using System.IO;
using System.Globalization;
using OpalKelly.FrontPanel;

namespace DESTester
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class DESTester
	{
		okCFrontPanel m_dev;


		public bool InitializeDevice()
		{
			okCFrontPanelDevices devices = new okCFrontPanelDevices();
			m_dev = devices.Open();
			if (m_dev == null)
			{
				Console.WriteLine("A device could not be opened.  Is one connected?");
				return(false);
			}

			// Get some general information about the device.
			okTDeviceInfo devInfo = new okTDeviceInfo();
			m_dev.GetDeviceInfo(devInfo);
			Console.WriteLine("Device firmware version: " +
				devInfo.deviceMajorVersion + "." +
				devInfo.deviceMinorVersion);
			Console.WriteLine("Device serial number: " + devInfo.serialNumber);
			Console.WriteLine("Device ID: " + devInfo.deviceID);

			// Setup the PLL from defaults.
			m_dev.LoadDefaultPLLConfiguration();

			// Download the configuration file.
			if (okCFrontPanel.ErrorCode.NoError != m_dev.ConfigureFPGA("des.bit")) {
				Console.WriteLine("FPGA configuration failed.");
				return(false);
			}

			// Check for FrontPanel support in the FPGA configuration.
			if (false == m_dev.IsFrontPanelEnabled()) {
				Console.WriteLine("FrontPanel support is not available.");
				return(false);
			}
			
			Console.WriteLine("FrontPanel support is available.");

			return(true);
		}


		public void SetKey(byte[] key)
		{
			for (int i=0; i<8; i++)
				m_dev.SetWireInValue((int)(0x0f - i), (uint)key[i], (uint)0xff);
			m_dev.UpdateWireIns();
		}

		public void ResetDES()
		{
			m_dev.SetWireInValue((int)0x10, (uint)0xff, (uint)0x01);
			m_dev.UpdateWireIns();
			m_dev.SetWireInValue((int)0x10, (uint)0x00, (uint)0x01);
			m_dev.UpdateWireIns();
		}

		private void EncryptDecrypt(String infile, String outfile)
		{
			Stream fileIn, fileOut;

			try 
			{
				fileIn = File.OpenRead(infile);
				fileOut = File.Create(outfile);
			}
			catch (FileNotFoundException)
			{
				return;
			}

			byte [] buf = new byte[2048];

			// Reset the RAM address pointer.
			m_dev.ActivateTriggerIn((short)0x41, (short)0);

			int got, len, i;
			got = 0;
			while (true) 
			{
				try 
				{
					got = fileIn.Read(buf, 0, 2048);
				}
				catch (IOException)
				{
					return;
				}

				if (got <= 0)
					return;

				if (got < 2048)
					for (i=got; i<2048; buf[i++]=0);

				// Write a block of data.
				m_dev.ActivateTriggerIn((short)0x41, (short)0);
				m_dev.WriteToPipeIn((short)0x80, 2048, buf);

				// Perform DES on the block.
				m_dev.ActivateTriggerIn((short)0x40, (short)0);

				// Wait for the TriggerOut indicating DONE.
				for (i=0; i<10; i++) 
				{
					m_dev.UpdateTriggerOuts();
					if (m_dev.IsTriggered((short)0x60, (uint)1))
						break;
				}

				len = 2048;
				m_dev.ReadFromPipeOut((short)0xa0, len, buf);

				try 
				{
					fileOut.Write(buf, 0, 2048);
				}
				catch (Exception)
				{
				}
			}
		}

		public void Encrypt(String infile, String outfile)
		{
			Console.WriteLine("Encrypting " + infile + " ---> " + outfile);

			// Set the encrypt Wire In.
			m_dev.SetWireInValue((int)0x10, (uint)0x00, (uint)0x10);
			m_dev.UpdateWireIns();

			EncryptDecrypt(infile, outfile);
		}

		public void Decrypt(String infile, String outfile)
		{
			Console.WriteLine("Decrypting " + infile + " ---> " + outfile);

			// Set the decrypt Wire In.
			m_dev.SetWireInValue((int)0x10, (uint)0xff, (uint)0x10);
			m_dev.UpdateWireIns();

			EncryptDecrypt(infile, outfile);
		}

		
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			Console.WriteLine("------ DES Encrypt/Decrypt Tester in C# ------");

			DESTester des = new DESTester();
			if (false == des.InitializeDevice())
				return;
			des.ResetDES();

			if (args.GetLength(0) != 4) 
			{
				Console.WriteLine("Usage: DESTester [d|e] key infile outfile");
				Console.WriteLine("   [d|e]   - d to decrypt the input file.  e to encrypt it.");
				Console.WriteLine("   key     - 64-bit hexadecimal string used for the key.");
				Console.WriteLine("   infile  - an input file to encrypt/decrypt.");
				Console.WriteLine("   outfile - destination output file.");
				return;
			}

			// Get the hex digits entered as the key
			byte[] key = new byte[8];
				String strkey = args[1];
			for (int i=0; i<8; i++) 
				key[i] = Byte.Parse(strkey.Substring(i*2, 2), NumberStyles.HexNumber);
			des.SetKey(key);

			// Encrypt or decrypt
			if (args[0][0] == 'd') 
				des.Decrypt(args[2], args[3]);
			else
				des.Encrypt(args[2], args[3]);
		}
	}
}
