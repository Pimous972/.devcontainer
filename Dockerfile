FROM php:8.3-cli

# Dependencies
RUN apt-get update \
    && apt-get install -y \
        git \
        libicu-dev \
        libpq-dev \
        libzip-dev \
        unzip \
        wget \
        zip \
        curl \
        htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Config mémoire PHP avec variable
ARG PHP_MEMORY_LIMIT=512M
RUN echo "memory_limit=${PHP_MEMORY_LIMIT}" > /usr/local/etc/php/conf.d/memory-limit.ini


# PHP Extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    mbstring \
    ctype \
    pdo_pgsql \
    tokenizer \
    pdo_mysql \
    mysqli \
    zip \
    xml

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony \
    && rm -rf /root/.symfony*


# Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Bash configuration (global)
RUN echo "alias ll='ls -lah'" >> /etc/bash.bashrc && \
    echo "alias ss='symfony serve -d --listen-ip=0.0.0.0'" >> /etc/bash.bashrc && \
    echo "alias symc='symfony console'" >> /etc/bash.bashrc && \
    echo "alias slog='symfony server:log'" >> /etc/bash.bashrc && \
    echo "PS1='\n \[\033[0;35m\]┌──(\[\033[1;33m\]\u@\h\[\033[0;35m\])─($(hostname -I | cut -d \" \" -f 1))─(\[\033[1;32m\]\w\[\033[0;35m\]) \t \n \[\033[0;35m\]└> ​​\[\033[1;35m\]\$ \[\033[0m\]'" >> /etc/bash.bashrc

# Ajout utilisateur non-root
# Ajout utilisateur non-root
RUN useradd -ms /bin/bash code \
    && echo "[ -f ~/.bashrc ] && . ~/.bashrc" >> /home/code/.bash_profile \
    && chown code:code /home/code/.bash_profile
USER code

# Working directory
WORKDIR /workspace

CMD ["bash", "-il"]