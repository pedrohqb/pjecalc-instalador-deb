#!/bin/bash

# --- Configurações do pacote ---
# Nome do pacote (tudo em letras minúsculas)
PACKAGE_NAME="pjecalc-instalador"
# Versão do pacote.
PACKAGE_VERSION="1.25.04.17"
# Descrição curta do pacote
DESCRIPTION_SHORT="Instalador do PJe-Calc e ferramentas de apoio"
# Descrição longa (pode ter várias linhas)
DESCRIPTION_LONG="Este pacote contém scripts de instalação, atalhos e documentação para o PJe-Calc e ferramentas relacionadas, como limpeza de navegador e backup."
# Mantenedor do pacote
MAINTAINER="Pedro Henrique Quitete Barreto <tuxslack@gmail.com>"
# Arquitetura
ARCHITECTURE="amd64"
# Dependências
DEPENDS="zulu-11, p7zip, yad, fonts-noto-color-emoji, gnome-icon-theme, libnotify-bin, net-tools, xfonts-base"

# --- Diretórios ---
# Repositório Git a ser clonado
REPO_URL="https://github.com/tuxslack/pjecalc-instalador.git"
# Diretório de trabalho para a construção
BUILD_DIR="${PACKAGE_NAME}-${PACKAGE_VERSION}"
# Diretório onde os arquivos do pacote serão organizados
DEB_ROOT_DIR="${BUILD_DIR}/"
# Diretório de controle
DEBIAN_DIR="${DEB_ROOT_DIR}/DEBIAN"

echo "Iniciando a criação do pacote .deb para o PJe-Calc Instalador..."

# --- Limpeza de compilações anteriores ---
if [ -d "$BUILD_DIR" ]; then
    echo "Limpando diretório de compilação anterior..."
    rm -rf "$BUILD_DIR"
fi

# --- 1. Clonar o repositório Git ---
echo "Clonando o repositório do PJe-Calc Instalador..."
git clone "$REPO_URL" "$BUILD_DIR"

if [ $? -ne 0 ]; then
    echo "Erro: Falha ao clonar o repositório. Verifique a URL e sua conexão."
    exit 1
fi

# --- 2. Preparar a estrutura do pacote ---
echo "Preparando a estrutura do pacote..."
# Remover arquivos desnecessários do diretório de compilação
rm -f "${DEB_ROOT_DIR}/LICENSE"
rm -f "${DEB_ROOT_DIR}/README.md"
rm -rf "${DEB_ROOT_DIR}/.git"

# Define permissões de execução para os scripts em /usr/local/bin
echo "Definindo permissões de execução para os scripts em /usr/local/bin..."
chmod -R +x "${DEB_ROOT_DIR}/usr/local/bin/"

# Criar a pasta DEBIAN
mkdir -p "$DEBIAN_DIR"

# --- 3. Criar o arquivo DEBIAN/control ---
echo "Criando o arquivo 'control'..."
cat > "${DEBIAN_DIR}/control" <<- EOT
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION
Section: utils
Priority: optional
Architecture: $ARCHITECTURE
Depends: $DEPENDS
Installed-Size: $(du -sh ${DEB_ROOT_DIR} | awk '{print $1}' | sed 's/M//' | sed 's/K//' | sed 's/G//')
Maintainer: $MAINTAINER
Homepage: $REPO_URL
Description: $DESCRIPTION_SHORT
 $DESCRIPTION_LONG
EOT

# --- 4. Construir o pacote .deb ---
echo "Construindo o pacote .deb..."
dpkg-deb --build "$BUILD_DIR"

if [ $? -eq 0 ]; then
    echo "--- Sucesso! ---"
    echo "Pacote criado: ${PACKAGE_NAME}-${PACKAGE_VERSION}.deb"
    echo "Você pode instalá-lo com: sudo dpkg -i ${PACKAGE_NAME}-${PACKAGE_VERSION}.deb"
else
    echo "--- Erro! ---"
    echo "Falha ao construir o pacote .deb."
fi

# --- 5. Limpar diretório de trabalho ---
echo "Limpando o diretório de trabalho..."
rm -rf "$BUILD_DIR"

echo "Processo concluído."
