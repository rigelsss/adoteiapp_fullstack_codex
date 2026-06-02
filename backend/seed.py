import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app.core.security import hash_text
from app.db.database import Base, SessionLocal, engine
from app.db.models import Pet, User

Base.metadata.create_all(bind=engine)

SEED_EMAIL = "seed_ana@adotei.com"


def seed():
    db = SessionLocal()

    if db.query(User).filter(User.email == SEED_EMAIL).first():
        print("Banco já possui dados de seed. Delete adotei.db e rode novamente para recriar.")
        db.close()
        return

    # --- Usuários de teste ---
    ana = User(
        nome="Ana", sobrenome="Lima", email=SEED_EMAIL,
        senha_hash=hash_text("123456"),
        pergunta_seguranca="Nome do seu primeiro pet?",
        resposta_seguranca_hash=hash_text("rex"),
        cidade="São Paulo", estado="SP",
    )
    carlos = User(
        nome="Carlos", sobrenome="Souza", email="seed_carlos@adotei.com",
        senha_hash=hash_text("123456"),
        pergunta_seguranca="Cidade onde nasceu?",
        resposta_seguranca_hash=hash_text("recife"),
        cidade="Recife", estado="PE",
    )
    db.add_all([ana, carlos])
    db.commit()
    db.refresh(ana)
    db.refresh(carlos)

    # --- Pets ---
    pets = [
        # São Paulo — Ana
        Pet(nome="Rex", especie="cão", raca="Labrador", idade=24, porte="grande",
            descricao="Muito dócil e brincalhão. Adora crianças e outros animais. Vacinado e castrado.",
            foto_url="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400",
            cidade="São Paulo", estado="SP", dono_id=ana.id),

        Pet(nome="Mimi", especie="gato", raca="Persa", idade=18, porte="pequeno",
            descricao="Calma e carinhosa. Ótima para apartamento. Já usa caixinha de areia.",
            foto_url="https://images.unsplash.com/photo-1535268647677-300dbf3d78d1?w=400",
            cidade="São Paulo", estado="SP", dono_id=ana.id),

        Pet(nome="Bolt", especie="cão", raca="Border Collie", idade=8, porte="médio",
            descricao="Filhote cheio de energia. Precisa de espaço e exercício diário.",
            foto_url="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400",
            cidade="São Paulo", estado="SP", dono_id=ana.id),

        Pet(nome="Luna", especie="gato", raca="Siamês", idade=36, porte="pequeno",
            descricao="Independente mas muito afetuosa na hora certa. Adora janelas.",
            foto_url="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400",
            cidade="Campinas", estado="SP", dono_id=ana.id),

        Pet(nome="Pipoca", especie="coelho", raca="Mini Rex", idade=6, porte="pequeno",
            descricao="Muito curiosa e sociável. Já acostumada com humanos. Vem com gaiola.",
            foto_url="https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=400",
            cidade="São Paulo", estado="SP", dono_id=ana.id),

        Pet(nome="Thor", especie="cão", raca="Golden Retriever", idade=12, porte="grande",
            descricao="Extremamente dócil. Ótimo com crianças. Já treinado com comandos básicos.",
            foto_url="https://images.unsplash.com/photo-1552053831-71594a27632d?w=400",
            cidade="São Paulo", estado="SP", dono_id=ana.id),

        Pet(nome="Nina", especie="cão", raca="SRD", idade=48, porte="médio",
            descricao="Resgatada da rua. Muito carinhosa e leal. Ama passear.",
            foto_url="https://images.unsplash.com/photo-1601979031925-424e53b6caaa?w=400",
            cidade="Santo André", estado="SP", dono_id=ana.id),

        Pet(nome="Toto", especie="pássaro", raca="Calopsita", idade=24, porte="pequeno",
            descricao="Fala algumas palavras e adora música. Sociável com outros pássaros.",
            foto_url="https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400",
            cidade="São Paulo", estado="SP", dono_id=ana.id),

        # Recife — Carlos
        Pet(nome="Mel", especie="gato", raca="SRD", idade=10, porte="pequeno",
            descricao="Filhota laranjinha, muito brincalhona. Primeira vacinação feita.",
            foto_url="https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Duque", especie="cão", raca="Beagle", idade=30, porte="médio",
            descricao="Adora farejar e explorar. Ótimo faro. Precisa de quintal.",
            foto_url="https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Fifi", especie="cão", raca="Poodle", idade=60, porte="pequeno",
            descricao="Dócil e inteligente. Já castrada e com todas as vacinas em dia.",
            foto_url="https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400",
            cidade="Olinda", estado="PE", dono_id=carlos.id),

        Pet(nome="Simba", especie="gato", raca="Maine Coon", idade=14, porte="médio",
            descricao="Grande e peludo, muito manso. Adora colo e não arranha móveis.",
            foto_url="https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Branca", especie="coelho", raca="Angorá", idade=8, porte="pequeno",
            descricao="Pelagem branca e macia. Muito tranquila. Ideal para apartamento.",
            foto_url="https://images.unsplash.com/photo-1606574977634-5e04c2a0ccc8?w=400",
            cidade="Caruaru", estado="PE", dono_id=carlos.id),

        Pet(nome="Goku", especie="cão", raca="Shiba Inu", idade=18, porte="médio",
            descricao="Independente e leal. Não se dá muito com estranhos mas ama a família.",
            foto_url="https://images.unsplash.com/photo-1579213838058-a8bdf06b1da4?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Coco", especie="pássaro", raca="Periquito", idade=12, porte="pequeno",
            descricao="Verde e amarelo, muito alegre. Canta o dia todo. Vem com gaiola.",
            foto_url="https://images.unsplash.com/photo-1544923246-77307dd654cb?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),
    ]

    db.add_all(pets)
    db.commit()

    print(f"Seed concluído: 2 usuários e {len(pets)} pets criados.")
    print("Credenciais de teste:")
    print("  ana@adotei.com    / 123456")
    print("  carlos@adotei.com / 123456")
    db.close()


if __name__ == "__main__":
    seed()
