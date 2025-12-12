# 🚀 GoNoGo App: Entregável Final (Revisão de Arquitetura e Gestão)

Este repositório contém o código-fonte final do aplicativo GoNoGo, desenvolvido com foco na arquitetura Cross-Platform e na integração com o Google Firebase.

## 🎯 Arquitetura de Software

O projeto utiliza o stack tecnológico moderno e escalável, garantindo eficiência e segurança.

### 1. Frontend (Mobile e Web)
* **Tecnologia:** **Flutter** (Framework Cross-Platform).
* **Linguagem:** **Dart**.
* **Justificativa:** A escolha do Flutter permite o uso de uma **única base de código** para compilar para diversas plataformas (Web, Android, iOS), otimizando o tempo de desenvolvimento em comparação com o desenvolvimento nativo tradicional.

### 2. Backend e Hospedagem
* **Plataforma:** **Google Firebase** (Plataforma Backend as a Service).
* **Hospedagem:** O aplicativo está hospedado no Firebase Hosting (demonstrado em [seu link de hosting]).
* **Autenticação:** Gerenciada pelo Firebase Authentication.

### 3. Banco de Dados (Persistência de Dados)
* **Tecnologia:** **Cloud Firestore** (Recomendação Padrão do Firebase para novos projetos).
* **Tipo:** Banco de dados **NoSQL**, baseado em documentos.
* **Vantagem:** Suporte nativo a atualizações **em tempo real** e alta escalabilidade, ideal para gerenciamento de listas dinâmicas, como cadastros e pedidos.

## ⚙️ Notas de Gestão e Implementação

* **Versionamento:** O código aqui presente representa o entregável final, isolado em um único *commit* para gestão de versão, a partir da branch de desenvolvimento mais recente.
* **Null Safety:** O código foi desenvolvido seguindo as diretrizes de *Null Safety* do Dart, utilizando explicitamente a sintaxe `?` onde valores nulos são permitidos, prevenindo erros em tempo de execução.
* **Imutabilidade:** As classes e variáveis essenciais utilizam os modificadores `final` e `const` para garantir imutabilidade e otimização de tempo de compilação quando aplicável.

## 🧑‍💻 Para Execução Local

Para rodar este projeto:
1.  Clone o repositório: `git clone https://github.com/patriciaalsousa/Go-No-Go_app_final`
2.  Instale as dependências: `flutter pub get`
3.  Execute: `flutter run`
