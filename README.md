# ufrgs-projects
Central para projetos realizados como atividade curricular da UFRGS.



# Criado usando git subtree
https://developer.atlassian.com/blog/2015/05/the-power-of-git-subtree/

###### $HOME/.gitconfig
Editar ./path/to/scripts.

```
[alias]
# "subtree add"
  sba = "!f() { ./path/to/scripts/add }; f"
# "subtree remove"
  sbr = "!f() { ./path/to/scripts/remove }; f"
# "subtree update"
  sbu = "!f() { ./path/to/scripts/update }; f"
# "subtree update all"
  sbua = "!f() { ./path/to/scripts/updateAll }; f"
```

##### Adicionar pastas de repositórios
```
git sba <repository uri> <destination folder>
```

##### Remover pastas de repositórios
```
git sbr <destination folder>
```

##### Atualizar uma pasta de repositório
```
git sbu <repository uri> <destination folder>
```

##### Atualizar todas pastas

```
git sbua
```
