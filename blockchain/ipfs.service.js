import PinataClient from "pinata-web3";

const pinata = new PinataClient({
  pinataJwt: process.env.PINATA_JWT
});

export async function uploadFileToIPFS(file) {
  const result = await pinata.upload.file(file);
  return result.IpfsHash; // CID
}
