FROM php:8.3-cli

# Mettre à jour les paquets et installer des dépendances
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git unzip nano vim tree curl npm htop wget bash sudo ca-certificates lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP Extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath gd imagick intl mbstring http ctype \
    pdo_pgsql tokenizer pdo_mysql mysqli zip xml

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir les arguments pour l'UID et le GID du développeur
ARG USER_ID=1000
ARG GROUP_ID=1000

# Créer un utilisateur "code" avec UID/GID
RUN groupadd -g $GROUP_ID code \
    && useradd -m -u $USER_ID -g code -s /bin/bash code \
    && echo "code:password" | chpasswd \
    && mkdir /home/code/workspace \
    && chown -R code:code /home/code/

# Passer à l'utilisateur "code"
USER code
WORKDIR /home/code

# Installer NVM, Node.js et Yarn
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install 20 && \
    nvm use 20 && \
    npm install --global yarn

# Installer PNPM
RUN curl -fsSL https://get.pnpm.io/install.sh | /bin/bash -

# Revenir à root pour ajouter l'utilisateur "code" à sudoers
USER root
RUN echo "code ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Rendre NVM disponible pour tous les shells de "code"
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/code/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /home/code/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"' >> /home/code/.bashrc && \
    chown -R code:code /home/code/.nvm

# Configuration de .bashrc pour l'utilisateur "code"
RUN echo "alias ll='ls -lah'" >> /home/code/.bashrc && \
    echo "alias ss='symfony serve -d --listen-ip=0.0.0.0'" >> /home/code/.bashrc && \
    echo "alias symc='symfony console'" >> /home/code/.bashrc && \
    echo "alias slog='symfony server:log'" >> /home/code/.bashrc && \
    echo "PS1='\n \[\033[0;35m\]┌──(\[\033[1;34m\]\u\[\033[0;35m\]@\[\033[1;32m\]\h\[\033[0;35m\])─($(hostname -I | cut -d " " -f 1))─(\[\033[1;32m\]\w\[\033[0;35m\]) \t \n \[\033[0;35m\]└> \[\033[1;35m\]\$ \[\033[0m\]'" >> /home/code/.bashrc && \
    echo "PS1='\n \[\033[0;31m\]┌──(\[\033[1;31m\]\u\[\033[0;31m\]@\[\033[1;32m\]\h\[\033[0;31m\])─($(hostname -I | cut -d " " -f 1))─(\[\033[1;32m\]\w\[\033[0;31m\]) \t \n \[\033[0;31m\]└> \[\033[1;31m\]\$ \[\033[0m\]'" >> /root/.bashrc && \
    chown code:code /home/code/.bashrc  

# Installer la Symfony CLI en tant qu'utilisateur root
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Exposer les ports pour le développement
EXPOSE 8000 5173 4200

# Définir le répertoire de travail
WORKDIR /home/code
