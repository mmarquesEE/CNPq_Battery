clc

% Expressão regular para as extensões desejadas
extension_pattern = '\.(mldatx|mexw64|asv|slxc)$';

% Lista de arquivos correspondentes à expressão regular
files_to_remove = dir(fullfile('**', '*'));
files_to_remove = files_to_remove(~cellfun('isempty', regexp({files_to_remove.name}, extension_pattern)));

% Adicionar o diretório 'resources' à lista de diretórios a serem removidos
directories_to_remove = {'resources'};

% Remover do rastreamento cada arquivo correspondente
for i = 1:length(files_to_remove)
    file_path = fullfile(files_to_remove(i).folder, files_to_remove(i).name);
    system(['git rm --cached "', file_path, '"']);
end

% Remover do rastreamento cada diretório correspondente
for i = 1:length(directories_to_remove)
    dir_path = directories_to_remove{i};
    system(['git rm --cached -r "', dir_path, '"']);
end

% Adicionar e fazer commit das alterações
system('git add .');
system('git commit -m "Remover do rastreamento arquivos e diretórios correspondentes à expressão regular"');
