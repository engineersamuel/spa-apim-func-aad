import React from "react";
import Main from "./components/Main";
import { PageLayout } from "./components/PageLayout";
import "./styles/App.css";

const App: React.FC = () => {
  return (
    <PageLayout>
      <Main />
    </PageLayout>
  );
}

export default App;