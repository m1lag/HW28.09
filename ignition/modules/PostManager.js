import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("PostManagerModule", (m) => {
  const postManager = m.contract("PostManager");

  return { postManager };
});