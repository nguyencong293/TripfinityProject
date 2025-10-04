import { useContext } from "react";
import ServerStatusContext from "../contexts/ServerErrorContext";

export const useServerStatus = () => {
  const context = useContext(ServerStatusContext);
  if (!context) {
    throw new Error("useServerStatus must be used within ServerStatusProvider");
  }
  return context;
};
