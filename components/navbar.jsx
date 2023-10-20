let logo = "<logo>";
let title = "Habilidash";

const menu = [
  {
    name: "Mis servicios",
  },
  {
    name: "Buscar Servicios",
  },
  {
    name: "Stake",
  },
  {
    name: "Subasta",
  },
  {
    name: "Verificarse",
  },
];

const Logo = styled.h2`
font-size: 26px;
color:#ADFF2F;
`;
const Navbar = styled.div`
background-color:#000000;
color:#ADFF2F;
display: flex;
justify-content: space-between;
 align-items: center;
 font-family: Space Grotesk;
`;

const MenuStyle = styled.div`
display: flex;
gap:12px;
align-items: left;
`;

const MenuItem = styled.h2`
font-size: 13px;
color:#A5F52A;
  &:hover {
    font-size: 13.5px;
    border: 16px;
    color:#ADFF2F;
    background-color:#232323;
  }
`;

return (
  <div>
    <Navbar>
      <Logo>{title}</Logo>
      <Logo>{logo}</Logo>

      <MenuStyle>
        {menu.map((data, index) => (
          <MenuItem>{data.name}</MenuItem>
        ))}
      </MenuStyle>
      <Widget src="tvh050423.near/widget/ConnectButton" props={{}} />
    </Navbar>
  </div>
);
